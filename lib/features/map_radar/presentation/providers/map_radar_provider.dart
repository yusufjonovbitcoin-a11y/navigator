import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/core/services/location_service.dart';
import 'package:navigator/features/map_radar/data/supabase_radar_repository.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/features/map_radar/domain/repositories/radar_repository.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

// Radar repository provider powered by Supabase (with offline fallback)
final radarRepositoryProvider = Provider<RadarRepository>((ref) {
  return SupabaseRadarRepository();
});

// Map target focus provider for navigating directly to a specific coordinate
final mapTargetFocusProvider = StateProvider<LatLng?>((ref) => null);

// Nearby radars state
class RadarListNotifier extends StateNotifier<AsyncValue<List<RadarPoint>>> {
  final RadarRepository _repo;

  RadarListNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadRadars();
  }

  Future<void> loadRadars({LatLng? center}) async {
    state = const AsyncValue.loading();
    try {
      final loc = center ?? const LatLng(39.654760, 66.975830);
      final list = await _repo.getNearbyRadars(
        lat: loc.latitude,
        lng: loc.longitude,
        radiusKm: 25.0,
      );
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> confirmRadar(String id) async {
    await _repo.confirmRadar(id);
    loadRadars();
  }

  Future<void> addCustomRadar(RadarPoint point) async {
    state.whenData((list) {
      state = AsyncValue.data([point, ...list]);
    });
    final repo = _repo;
    if (repo is SupabaseRadarRepository) {
      await repo.addRadar(point);
    }
  }
}

final radarListProvider =
    StateNotifierProvider<RadarListNotifier, AsyncValue<List<RadarPoint>>>((ref) {
  final repo = ref.watch(radarRepositoryProvider);
  return RadarListNotifier(repo);
});

// Radar proximity & alert state
class RadarAlertState {
  final RadarPoint? closestRadar;
  final double distanceMeters;
  final bool isWarningActive;
  final bool isOverSpeed;
  final double currentSpeedKmh;

  const RadarAlertState({
    this.closestRadar,
    this.distanceMeters = 0.0,
    this.isWarningActive = false,
    this.isOverSpeed = false,
    this.currentSpeedKmh = 0.0,
  });

  RadarAlertState copyWith({
    RadarPoint? closestRadar,
    double? distanceMeters,
    bool? isWarningActive,
    bool? isOverSpeed,
    double? currentSpeedKmh,
  }) {
    return RadarAlertState(
      closestRadar: closestRadar ?? this.closestRadar,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isWarningActive: isWarningActive ?? this.isWarningActive,
      isOverSpeed: isOverSpeed ?? this.isOverSpeed,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
    );
  }
}

class RadarAlertNotifier extends StateNotifier<RadarAlertState> {
  final Ref _ref;
  String? _lastAnnouncedRadarId;
  DateTime? _lastAnnouncementTime;

  RadarAlertNotifier(this._ref) : super(const RadarAlertState()) {
    _subscribeLocation();
  }

  void _subscribeLocation() {
    _ref.listen<AsyncValue<UserLocation>>(userLocationStreamProvider, (prev, next) {
      next.whenData((location) {
        _evaluateProximity(location);
      });
    });
  }

  void _evaluateProximity(UserLocation location) {
    final radarsAsync = _ref.read(radarListProvider);
    final settings = _ref.read(settingsNotifierProvider);
    final audio = _ref.read(audioAlertServiceProvider);

    radarsAsync.whenData((radars) {
      if (radars.isEmpty) {
        state = state.copyWith(currentSpeedKmh: location.speedKmh, isWarningActive: false);
        return;
      }

      RadarPoint? nearestAhead;
      double minDistanceAhead = double.infinity;
      RadarPoint? absoluteNearest;
      double minAbsoluteDistance = double.infinity;

      for (final r in radars) {
        final d = LocationService.calculateDistance(
          location.latitude,
          location.longitude,
          r.lat,
          r.lng,
        );

        if (d < minAbsoluteDistance) {
          minAbsoluteDistance = d;
          absoluteNearest = r;
        }

        // Check whether this radar is ahead of vehicle along driving direction
        final bearingToRadar = LocationService.calculateBearing(
          location.latitude,
          location.longitude,
          r.lat,
          r.lng,
        );
        double angleDiff = (bearingToRadar - location.heading).abs() % 360.0;
        if (angleDiff > 180.0) angleDiff = 360.0 - angleDiff;

        // Radar is in front of the vehicle within 110-degree cone (or vehicle is stopped)
        if (angleDiff <= 110.0 || location.speedKmh < 5.0) {
          if (d < minDistanceAhead) {
            minDistanceAhead = d;
            nearestAhead = r;
          }
        }
      }

      // Choose upcoming radar ahead; fallback to nearest if close (< 250m)
      final chosenRadar = nearestAhead ?? (minAbsoluteDistance < 250.0 ? absoluteNearest : null);
      final distanceMeters = (chosenRadar == nearestAhead) ? minDistanceAhead : minAbsoluteDistance;

      // Show upcoming radar banner up to 1500m away (Google Maps / Yandex countdown style!)
      const previewDistanceLimit = 1500.0;
      final isInsideWarning = chosenRadar != null && distanceMeters <= previewDistanceLimit;
      final speedLimit = chosenRadar?.speedLimit ?? 70;
      final isSpeeding = location.speedKmh > (speedLimit + 2);

      state = RadarAlertState(
        closestRadar: chosenRadar,
        distanceMeters: distanceMeters,
        isWarningActive: isInsideWarning,
        isOverSpeed: isInsideWarning && isSpeeding,
        currentSpeedKmh: location.speedKmh,
      );

      // Trigger voice chime & announcement once approaching within alert threshold (e.g. 500m)
      final alertDistance = settings.alertDistanceMeters.toDouble();
      if (isInsideWarning && distanceMeters <= alertDistance && settings.voiceAlertsEnabled) {
        final now = DateTime.now();
        final shouldAnnounce = _lastAnnouncedRadarId != chosenRadar.id ||
            (_lastAnnouncementTime == null ||
                now.difference(_lastAnnouncementTime!).inSeconds > 35);

        if (shouldAnnounce) {
          _lastAnnouncedRadarId = chosenRadar.id;
          _lastAnnouncementTime = now;
          audio.announceRadar(
            type: chosenRadar.type,
            radarType: chosenRadar.type.displayName,
            distanceMeters: distanceMeters.round(),
            speedLimit: speedLimit,
            languageCode: settings.language.code,
            isOverSpeed: isSpeeding,
          );
        }
      }
    });
  }

  void triggerTestAlert() {
    final settings = _ref.read(settingsNotifierProvider);
    final audio = _ref.read(audioAlertServiceProvider);
    audio.announceRadar(
      type: RadarType.stationary,
      radarType: 'Stationary Speed Camera',
      distanceMeters: 500,
      speedLimit: 70,
      languageCode: settings.language.code,
      isOverSpeed: false,
    );
  }
}

final radarAlertProvider =
    StateNotifierProvider<RadarAlertNotifier, RadarAlertState>((ref) {
  return RadarAlertNotifier(ref);
});

// Simulator Running State
final isSimulatingDriveProvider = StateProvider<bool>((ref) => false);
