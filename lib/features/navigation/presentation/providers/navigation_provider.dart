import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/core/services/voice_copilot_service.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_radar_provider.dart';
import 'package:navigator/features/navigation/data/osrm_route_repository.dart';
import 'package:navigator/features/navigation/domain/models/navigation_step.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';
import 'package:navigator/features/navigation/domain/repositories/route_repository.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

// Route Repository Provider using live OpenStreetMap OSRM engine
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return OsrmRouteRepository();
});

// Route Planning State
class RoutePlanningState {
  final LatLng origin;
  final LatLng? destination;
  final String originName;
  final String? destinationName;
  final List<RouteInfo> availableRoutes;
  final RouteInfo? selectedRoute;
  final bool isLoading;
  final String? error;

  const RoutePlanningState({
    this.origin = const LatLng(39.654760, 66.975830),
    this.destination,
    this.originName = 'Hozirgi joylashuv',
    this.destinationName,
    this.availableRoutes = const [],
    this.selectedRoute,
    this.isLoading = false,
    this.error,
  });

  RoutePlanningState copyWith({
    LatLng? origin,
    LatLng? destination,
    bool clearDestination = false,
    String? originName,
    String? destinationName,
    List<RouteInfo>? availableRoutes,
    RouteInfo? selectedRoute,
    bool clearSelectedRoute = false,
    bool? isLoading,
    String? error,
  }) {
    return RoutePlanningState(
      origin: origin ?? this.origin,
      destination: clearDestination ? null : (destination ?? this.destination),
      originName: originName ?? this.originName,
      destinationName: clearDestination ? null : (destinationName ?? this.destinationName),
      availableRoutes: availableRoutes ?? this.availableRoutes,
      selectedRoute: clearSelectedRoute ? null : (selectedRoute ?? this.selectedRoute),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RoutePlanningNotifier extends StateNotifier<RoutePlanningState> {
  final RouteRepository _repo;

  RoutePlanningNotifier(this._repo) : super(const RoutePlanningState());

  void setOrigin(LatLng origin, {String? originName}) {
    state = state.copyWith(origin: origin, originName: originName ?? state.originName);
  }

  Future<void> planRoute({LatLng? customDest, String? customDestName}) async {
    final dest = customDest ?? state.destination;
    if (dest == null) return;

    state = state.copyWith(
      isLoading: true,
      destination: dest,
      destinationName: customDestName ?? state.destinationName ?? 'Tanlangan manzil',
    );

    try {
      final routes = await _repo.planRoutes(
        origin: state.origin,
        destination: dest,
      );
      state = state.copyWith(
        availableRoutes: routes,
        selectedRoute: routes.isNotEmpty ? routes.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearDestination() {
    state = state.copyWith(
      clearDestination: true,
      clearSelectedRoute: true,
      availableRoutes: [],
    );
  }

  void selectRoute(RouteInfo route) {
    state = state.copyWith(selectedRoute: route);
  }
}

final routePlanningProvider =
    StateNotifierProvider<RoutePlanningNotifier, RoutePlanningState>((ref) {
  final repo = ref.watch(routeRepositoryProvider);
  return RoutePlanningNotifier(repo);
});

// Active Turn-by-Turn Navigation State
class ActiveNavState {
  final bool isNavigating;
  final RouteInfo? activeRoute;
  final int currentStepIndex;
  final NavigationStep? currentStep;
  final double distanceRemainingMeters;
  final int timeRemainingMinutes;
  final bool hasReroutePrompt;
  final RouteInfo? rerouteAlternative;

  const ActiveNavState({
    this.isNavigating = false,
    this.activeRoute,
    this.currentStepIndex = 0,
    this.currentStep,
    this.distanceRemainingMeters = 0.0,
    this.timeRemainingMinutes = 0,
    this.hasReroutePrompt = false,
    this.rerouteAlternative,
  });

  ActiveNavState copyWith({
    bool? isNavigating,
    RouteInfo? activeRoute,
    int? currentStepIndex,
    NavigationStep? currentStep,
    double? distanceRemainingMeters,
    int? timeRemainingMinutes,
    bool? hasReroutePrompt,
    RouteInfo? rerouteAlternative,
  }) {
    return ActiveNavState(
      isNavigating: isNavigating ?? this.isNavigating,
      activeRoute: activeRoute ?? this.activeRoute,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentStep: currentStep ?? this.currentStep,
      distanceRemainingMeters: distanceRemainingMeters ?? this.distanceRemainingMeters,
      timeRemainingMinutes: timeRemainingMinutes ?? this.timeRemainingMinutes,
      hasReroutePrompt: hasReroutePrompt ?? this.hasReroutePrompt,
      rerouteAlternative: rerouteAlternative ?? this.rerouteAlternative,
    );
  }
}

class ActiveNavNotifier extends StateNotifier<ActiveNavState> {
  final Ref _ref;

  ActiveNavNotifier(this._ref) : super(const ActiveNavState());

  void startNavigation(RouteInfo route) {
    final locationService = _ref.read(locationServiceProvider);

    state = ActiveNavState(
      isNavigating: true,
      activeRoute: route,
      currentStepIndex: 0,
      currentStep: route.steps.isNotEmpty ? route.steps.first : null,
      distanceRemainingMeters: route.distanceKm * 1000.0,
      timeRemainingMinutes: route.durationMinutes,
    );

    _ref.read(isSimulatingDriveProvider.notifier).state = true;
    _ref.read(voiceCopilotProvider.notifier).activateNavigationAudioSession();

    // Start drive simulation along polyline
    locationService.startDriveSimulation(
      waypoints: route.points,
      targetSpeedKmh: 68.0,
      onFinished: () {
        stopNavigation();
      },
    );

    // Trigger dynamic hazard re-route prompt after 8 seconds of navigation
    Future.delayed(const Duration(seconds: 8), () {
      if (state.isNavigating) {
        _triggerDynamicReroute();
      }
    });
  }

  Future<void> _triggerDynamicReroute() async {
    final repo = _ref.read(routeRepositoryProvider);
    final audio = _ref.read(audioAlertServiceProvider);
    final settings = _ref.read(settingsNotifierProvider);

    try {
      final alt = await repo.getAlternativeRoute(
        originalRouteId: state.activeRoute?.id ?? 'route-1',
        hazardId: 'patrol_detected',
      );

      state = state.copyWith(
        hasReroutePrompt: true,
        rerouteAlternative: alt,
      );

      if (settings.voiceAlertsEnabled) {
        audio.announceHazard(
          hazardType: 'Police radar detected ahead. Faster re-route found',
          distanceMeters: 800,
          languageCode: settings.language.code,
        );
      }
    } catch (_) {}
  }

  void acceptReroute() {
    if (state.rerouteAlternative != null) {
      final alt = state.rerouteAlternative!;
      state = state.copyWith(
        activeRoute: alt,
        hasReroutePrompt: false,
        rerouteAlternative: null,
        currentStep: alt.steps.isNotEmpty ? alt.steps.first : null,
      );
    }
  }

  void dismissReroute() {
    state = state.copyWith(hasReroutePrompt: false);
  }

  void stopNavigation() {
    _ref.read(locationServiceProvider).stopDriveSimulation();
    _ref.read(isSimulatingDriveProvider.notifier).state = false;
    _ref.read(voiceCopilotProvider.notifier).deactivateNavigationAudioSession();
    state = const ActiveNavState(isNavigating: false);
  }
}

final activeNavProvider =
    StateNotifierProvider<ActiveNavNotifier, ActiveNavState>((ref) {
  return ActiveNavNotifier(ref);
});
