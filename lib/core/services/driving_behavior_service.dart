import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/services/location_service.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum DrivingEventType {
  rapidAcceleration,
  harshBraking,
  sharpCornering,
  smoothDriving,
}

class DrivingEvent {
  final DrivingEventType type;
  final double magnitude;
  final DateTime timestamp;
  final String descriptionUz;
  final String descriptionRu;

  const DrivingEvent({
    required this.type,
    required this.magnitude,
    required this.timestamp,
    required this.descriptionUz,
    required this.descriptionRu,
  });
}

class DrivingBehaviorState {
  final double safetyScore; // 0 - 100
  final double weeklyDistanceKm;
  final int violationCount;
  final double fuelSavedPercentage;
  final int harshBrakingCount;
  final int rapidAccelerationCount;
  final int sharpCorneringCount;
  final double currentGForce;
  final List<DrivingEvent> recentEvents;

  const DrivingBehaviorState({
    this.safetyScore = 96.0,
    this.weeklyDistanceKm = 240.0,
    this.violationCount = 0,
    this.fuelSavedPercentage = 8.0,
    this.harshBrakingCount = 0,
    this.rapidAccelerationCount = 0,
    this.sharpCorneringCount = 0,
    this.currentGForce = 1.0,
    this.recentEvents = const [],
  });

  String getWeeklySummary(String langCode) {
    if (langCode == 'ru') {
      return 'На этой неделе вы проехали ${weeklyDistanceKm.toInt()} км. $violationCount нарушений. Ваш рейтинг безопасности: ${safetyScore.toInt()}/100. Вы сэкономили ${fuelSavedPercentage.toInt()}% топлива!';
    } else if (langCode == 'uz') {
      return 'Bu hafta ${weeklyDistanceKm.toInt()} km bosib o\'tdingiz. $violationCount ta qoidabuzarlik. Xavfsizlik balingiz: ${safetyScore.toInt()}/100. Siz yoqilg\'ini ${fuelSavedPercentage.toInt()}% ga tejadingiz!';
    } else {
      return 'You drove ${weeklyDistanceKm.toInt()} km this week. $violationCount violations. Safety score: ${safetyScore.toInt()}/100. You saved ${fuelSavedPercentage.toInt()}% fuel!';
    }
  }

  DrivingBehaviorState copyWith({
    double? safetyScore,
    double? weeklyDistanceKm,
    int? violationCount,
    double? fuelSavedPercentage,
    int? harshBrakingCount,
    int? rapidAccelerationCount,
    int? sharpCorneringCount,
    double? currentGForce,
    List<DrivingEvent>? recentEvents,
  }) {
    return DrivingBehaviorState(
      safetyScore: safetyScore ?? this.safetyScore,
      weeklyDistanceKm: weeklyDistanceKm ?? this.weeklyDistanceKm,
      violationCount: violationCount ?? this.violationCount,
      fuelSavedPercentage: fuelSavedPercentage ?? this.fuelSavedPercentage,
      harshBrakingCount: harshBrakingCount ?? this.harshBrakingCount,
      rapidAccelerationCount: rapidAccelerationCount ?? this.rapidAccelerationCount,
      sharpCorneringCount: sharpCorneringCount ?? this.sharpCorneringCount,
      currentGForce: currentGForce ?? this.currentGForce,
      recentEvents: recentEvents ?? this.recentEvents,
    );
  }
}

class DrivingBehaviorNotifier extends StateNotifier<DrivingBehaviorState> {
  final Ref _ref;
  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  double _lastSpeedKmh = 0.0;
  DateTime _lastSpeedTime = DateTime.now();

  DrivingBehaviorNotifier(this._ref) : super(const DrivingBehaviorState()) {
    _startSensors();
    _subscribeLocation();
  }

  void _startSensors() {
    try {
      userAccelerometerEventStream().listen(
        (event) {
          _processAccelerometer(event.x, event.y, event.z);
        },
        onError: (_) {
          // Graceful fallback on Simulator
        },
        cancelOnError: false,
      );
    } catch (_) {}
  }

  void _subscribeLocation() {
    _ref.listen<AsyncValue<UserLocation>>(userLocationStreamProvider, (prev, next) {
      next.whenData((loc) {
        _processGpsSpeed(loc.speedKmh);
      });
    });
  }

  void _processAccelerometer(double x, double y, double z) {
    final gForce = math.sqrt(x * x + y * y + z * z) / 9.81;

    // Lateral Acceleration (Cornering)
    if (x.abs() > 3.2) {
      _recordEvent(
        DrivingEventType.sharpCornering,
        x.abs(),
        'Keskin burilish aniqlandi',
        'Обнаружен резкий поворот',
      );
    }

    // Longitudinal (Braking / Acceleration)
    if (y < -3.5) {
      _recordEvent(
        DrivingEventType.harshBraking,
        y.abs(),
        'Keskin tormozlanish',
        'Резкое торможение',
      );
    } else if (y > 3.0) {
      _recordEvent(
        DrivingEventType.rapidAcceleration,
        y,
        'Tez keskin tezlanish',
        'Резкое ускорение',
      );
    }

    state = state.copyWith(currentGForce: gForce);
  }

  void _processGpsSpeed(double currentSpeedKmh) {
    final now = DateTime.now();
    final dtSeconds = now.difference(_lastSpeedTime).inMilliseconds / 1000.0;
    if (dtSeconds > 0.5 && dtSeconds < 3.0) {
      final dSpeedKmh = currentSpeedKmh - _lastSpeedKmh;
      final speedRate = dSpeedKmh / dtSeconds; // km/h per second

      // Speed rate: if braking harder than -15 km/h per sec
      if (speedRate < -15.0) {
        _recordEvent(
          DrivingEventType.harshBraking,
          speedRate.abs(),
          'GPS: Keskin tormoz',
          'GPS: Резкое торможение',
        );
      } else if (speedRate > 14.0) {
        _recordEvent(
          DrivingEventType.rapidAcceleration,
          speedRate,
          'GPS: Keskin tezlanish',
          'GPS: Резкий разгон',
        );
      }
    }

    _lastSpeedKmh = currentSpeedKmh;
    _lastSpeedTime = now;
  }

  void _recordEvent(
    DrivingEventType type,
    double magnitude,
    String descUz,
    String descRu,
  ) {
    int harshBrakes = state.harshBrakingCount;
    int rapidAccels = state.rapidAccelerationCount;
    int sharpTurns = state.sharpCorneringCount;

    if (type == DrivingEventType.harshBraking) harshBrakes++;
    if (type == DrivingEventType.rapidAcceleration) rapidAccels++;
    if (type == DrivingEventType.sharpCornering) sharpTurns++;

    // Calculate dynamic safety score based on penalty weights
    final penalty = (harshBrakes * 1.5) + (rapidAccels * 1.0) + (sharpTurns * 1.2);
    final score = (100.0 - penalty).clamp(60.0, 100.0);

    final event = DrivingEvent(
      type: type,
      magnitude: magnitude,
      timestamp: DateTime.now(),
      descriptionUz: descUz,
      descriptionRu: descRu,
    );

    final updatedEvents = [event, ...state.recentEvents].take(20).toList();

    state = state.copyWith(
      safetyScore: score,
      harshBrakingCount: harshBrakes,
      rapidAccelerationCount: rapidAccels,
      sharpCorneringCount: sharpTurns,
      recentEvents: updatedEvents,
    );
  }

  void recordKilometers(double km) {
    state = state.copyWith(weeklyDistanceKm: state.weeklyDistanceKm + km);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }
}

final drivingBehaviorProvider =
    StateNotifierProvider<DrivingBehaviorNotifier, DrivingBehaviorState>((ref) {
  return DrivingBehaviorNotifier(ref);
});
