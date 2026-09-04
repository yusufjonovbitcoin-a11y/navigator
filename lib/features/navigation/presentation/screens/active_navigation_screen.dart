import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/core/services/location_service.dart';
import 'package:navigator/features/ai_agent/presentation/widgets/voice_assistant_overlay.dart';
import 'package:navigator/features/map_radar/domain/models/map_style.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_radar_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_style_provider.dart';
import 'package:navigator/features/map_radar/presentation/widgets/next_radar_banner.dart';
import 'package:navigator/features/map_radar/presentation/widgets/speedometer_hud.dart';
import 'package:navigator/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:navigator/features/navigation/presentation/widgets/navigation_turn_banner.dart';
import 'package:navigator/features/navigation/presentation/widgets/reroute_alert_dialog.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class ActiveNavigationScreen extends ConsumerStatefulWidget {
  const ActiveNavigationScreen({super.key});

  @override
  ConsumerState<ActiveNavigationScreen> createState() => _ActiveNavigationScreenState();
}

class _ActiveNavigationScreenState extends ConsumerState<ActiveNavigationScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _followCar = true;

  late AnimationController _animController;
  LatLng _animStartPos = const LatLng(39.654760, 66.975830);
  LatLng _animTargetPos = const LatLng(39.654760, 66.975830);
  double _animStartHeading = 0.0;
  double _animTargetHeading = 0.0;
  LatLng _currentRenderedPos = const LatLng(39.654760, 66.975830);
  double _currentRenderedHeading = 0.0;
  double _smoothedLookaheadHeading = 0.0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    if (!_followCar) return;

    final t = Curves.linear.transform(_animController.value);

    // 1. Smooth 60fps position interpolation
    final lat = _animStartPos.latitude + (_animTargetPos.latitude - _animStartPos.latitude) * t;
    final lng = _animStartPos.longitude + (_animTargetPos.longitude - _animStartPos.longitude) * t;
    final currentPos = LatLng(lat, lng);

    // 2. Shortest-path angular rotation interpolation (prevents 360 spin around North!)
    double diff = (_animTargetHeading - _animStartHeading) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    final currentHeading = (_animStartHeading + diff * t) % 360.0;

    // 3. Damped lookahead heading (eliminates camera wobble on micro-curves)
    _smoothedLookaheadHeading += (currentHeading - _smoothedLookaheadHeading) * 0.15;

    // 4. Project camera center ~55m forward along smoothed direction
    final lookRad = _smoothedLookaheadHeading * (math.pi / 180.0);
    const lookAheadMeters = 55.0;
    final latRad = lat * (math.pi / 180.0);
    final deltaLat = (lookAheadMeters * math.cos(lookRad)) / 111139.0;
    final deltaLng = (lookAheadMeters * math.sin(lookRad)) / (111139.0 * math.cos(latRad));
    final cameraCenter = LatLng(lat + deltaLat, lng + deltaLng);

    setState(() {
      _currentRenderedPos = currentPos;
      _currentRenderedHeading = currentHeading;
    });

    _mapController.moveAndRotate(cameraCenter, 17.5, -currentHeading);
  }

  void _onLocationReceived(UserLocation loc) {
    if (!_isInitialized) {
      _isInitialized = true;
      _currentRenderedPos = loc.latLng;
      _currentRenderedHeading = loc.heading;
      _smoothedLookaheadHeading = loc.heading;
      _animStartPos = loc.latLng;
      _animTargetPos = loc.latLng;
      _animStartHeading = loc.heading;
      _animTargetHeading = loc.heading;
      return;
    }

    if (!_followCar) return;

    _animStartPos = _currentRenderedPos;
    _animTargetPos = loc.latLng;
    _animStartHeading = _currentRenderedHeading;
    _animTargetHeading = loc.heading;

    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final navState = ref.watch(activeNavProvider);
    final alertState = ref.watch(radarAlertProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final mapStyle = ref.watch(mapStyleProvider);
    final radarsAsync = ref.watch(radarListProvider);
    final radars = radarsAsync.value ?? [];

    // Current car location snapshot
    final userLoc = ref.watch(userLocationStreamProvider).value;
    final carPos = userLoc?.latLng ?? _currentRenderedPos;
    final carHeading = userLoc?.heading ?? _currentRenderedHeading;

    // Listen to real-time car location updates and drive smooth 60fps interpolation
    ref.listen<AsyncValue<UserLocation>>(userLocationStreamProvider, (prev, next) {
      if (next.value != null) {
        _onLocationReceived(next.value!);
      }
    });

    final activeRoute = navState.activeRoute;
    final currentStep = navState.currentStep;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(activeNavProvider.notifier).stopNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Google Maps / Apple Maps Driving Map (Full Bleed Edge-to-Edge)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: carPos,
                  initialZoom: 17.5,
                  minZoom: 3.0,
                  maxZoom: 19.5,
                  initialRotation: -carHeading,
                  onPositionChanged: (pos, hasGesture) {
                    if (hasGesture && _followCar) {
                      setState(() => _followCar = false);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: mapStyle.urlTemplate,
                    fallbackUrl: mapStyle.fallbackUrl,
                    subdomains: mapStyle.subdomains,
                    userAgentPackageName: 'com.smartradar.navigator',
                    maxNativeZoom: mapStyle.maxNativeZoom,
                    maxZoom: 20,
                    panBuffer: 1,
                    keepBuffer: 3,
                    evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                    tileDisplay: const TileDisplay.fadeIn(duration: Duration(milliseconds: 150)),
                  ),

                  // Active Route Polyline with High Contrast Glow
                  if (activeRoute != null) ...[
                    // Route Shadow/Glow layer
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: activeRoute.points,
                          strokeWidth: 12.0,
                          color: (activeRoute.isSafest ? const Color(0xFF34C759) : const Color(0xFF007AFF)).withOpacity(0.35),
                        ),
                      ],
                    ),
                    // Core High-contrast Route Line
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: activeRoute.points,
                          strokeWidth: 7.5,
                          color: activeRoute.isSafest ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                        ),
                      ],
                    ),
                  ],

                  // Radar & Camera Markers Mounted on Pole (Always upright with rotate: true)
                  MarkerLayer(
                    rotate: true,
                    markers: [
                      ...radars.map((r) {
                        final isStationary = r.type == RadarType.stationary || r.type == RadarType.redLight;
                        final markerColor = isStationary ? AppColors.radarRed : const Color(0xFFFF9500);

                        return Marker(
                          point: r.latLng,
                          width: 64,
                          height: 56,
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Radar Head Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: markerColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: markerColor.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isStationary ? CupertinoIcons.camera_fill : CupertinoIcons.dot_radiowaves_left_right,
                                      color: markerColor,
                                      size: 11,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${r.speedLimit}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Vertical Pole
                              Container(
                                width: 2.5,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              // Base Dot
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  // 3D Navigation Vehicle Marker (Car Arrow pointing forward along road)
                  MarkerLayer(
                    rotate: false,
                    markers: [
                      Marker(
                        point: _currentRenderedPos,
                        width: 68,
                        height: 68,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing Directional Pulse
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF00E5FF).withOpacity(0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // 3D Navigation Puck
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF007AFF), Color(0xFF0051C6)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007AFF).withOpacity(0.6),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.location_north_fill,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 2. Apple Maps Turn-by-Turn Header & Dynamic Alerts (Top Pinned)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Turn-by-Turn Navigation Header
                        if (currentStep != null)
                          NavigationTurnBanner(
                            step: currentStep,
                            distanceRemainingMeters: navState.distanceRemainingMeters,
                          ),
                        const SizedBox(height: 8),

                        // Radar Alert Banner if approaching radar
                        if (alertState.isWarningActive && alertState.closestRadar != null)
                          NextRadarBanner(
                            radar: alertState.closestRadar!,
                            distanceMeters: alertState.distanceMeters,
                            isOverSpeed: alertState.isOverSpeed,
                            onTestVoice: () {
                              ref.read(radarAlertProvider.notifier).triggerTestAlert();
                            },
                          ),

                        // Dynamic Reroute Banner
                        if (navState.hasReroutePrompt && navState.rerouteAlternative != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RerouteAlertBanner(
                              alternativeRoute: navState.rerouteAlternative!,
                              onAccept: () => ref.read(activeNavProvider.notifier).acceptReroute(),
                              onDismiss: () => ref.read(activeNavProvider.notifier).dismissReroute(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Apple CarPlay Speedometer HUD (Bottom Left, above dock)
              Positioned(
                left: 16,
                bottom: 120,
                child: SpeedometerHud(
                  currentSpeedKmh: alertState.currentSpeedKmh,
                  speedLimitKmh: alertState.closestRadar?.speedLimit ?? 70,
                  isWarningActive: alertState.isWarningActive,
                ),
              ),

              // 4. Recenter Button (Shown when user manually panned away)
              if (!_followCar)
                Positioned(
                  right: 16,
                  bottom: 120,
                  child: FloatingActionButton.extended(
                    heroTag: 'recenter_nav',
                    backgroundColor: const Color(0xFF0F172A).withOpacity(0.95),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _followCar = true);
                      _animStartPos = _currentRenderedPos;
                      _animTargetPos = carPos;
                      _animStartHeading = _currentRenderedHeading;
                      _animTargetHeading = carHeading;
                      _animController.forward(from: 0.0);
                    },
                    icon: const Icon(CupertinoIcons.location_north_fill, color: AppColors.primary, size: 18),
                    label: const Text(
                      'Markaz',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),

              // 5. Apple CarPlay Bottom Navigation Dock (ETA, Voice Toggle, End Navigation)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.92),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.14))),
                      ),
                      child: Row(
                        children: [
                          // ETA Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${navState.timeRemainingMinutes} min',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF34C759),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${(navState.distanceRemainingMeters / 1000).toStringAsFixed(1)} km)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeRoute?.name ?? 'Navigating',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Voice Assistant "Hey Radar" Button
                          GestureDetector(
                            onTap: () {
                              VoiceAssistantOverlay.show(context);
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                CupertinoIcons.mic_fill,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Voice Mute/Unmute Toggle
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(settingsNotifierProvider.notifier).setVoiceAlerts(!settings.voiceAlertsEnabled);
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                settings.voiceAlertsEnabled ? CupertinoIcons.speaker_2_fill : CupertinoIcons.speaker_slash_fill,
                                color: settings.voiceAlertsEnabled ? AppColors.primary : Colors.white54,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // End Navigation Button (Apple CarPlay style red pill)
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            color: const Color(0xFFFF3B30),
                            borderRadius: BorderRadius.circular(20),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              ref.read(activeNavProvider.notifier).stopNavigation();
                              Navigator.pop(context);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.xmark, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  tr.tr('close'),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
