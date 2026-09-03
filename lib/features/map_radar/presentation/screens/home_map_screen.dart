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
import 'package:navigator/core/services/osrm_routing_service.dart';
import 'package:navigator/features/map_radar/domain/models/map_style.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_filter_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_placement_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_radar_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_style_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/parking_zone_provider.dart';
import 'package:navigator/features/map_radar/presentation/widgets/add_custom_object_sheet.dart';
import 'package:navigator/features/map_radar/presentation/widgets/map_placement_hud.dart';
import 'package:navigator/features/map_radar/presentation/widgets/next_radar_banner.dart';
import 'package:navigator/features/map_radar/presentation/widgets/parking_drawing_hud.dart';
import 'package:navigator/features/map_radar/presentation/widgets/parking_zone_info_sheet.dart';
import 'package:navigator/features/map_radar/presentation/widgets/quick_report_sheet.dart';
import 'package:navigator/features/map_radar/presentation/widgets/radar_detail_sheet.dart';
import 'package:navigator/features/map_radar/presentation/widgets/speedometer_hud.dart';
import 'package:navigator/features/navigation/presentation/screens/route_planning_screen.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';
import 'package:navigator/features/reports/presentation/widgets/report_item_card.dart';
import 'package:navigator/core/services/voice_copilot_service.dart';
import 'package:navigator/features/ai_agent/presentation/widgets/voice_assistant_overlay.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(39.654760, 66.975830);
  bool _followUser = true;
  List<LatLng> _simulatedRoutePoints = [];

  late AnimationController _animController;
  LatLng _animStartPos = const LatLng(39.654760, 66.975830);
  LatLng _animTargetPos = const LatLng(39.654760, 66.975830);
  double _animStartHeading = 0.0;
  double _animTargetHeading = 0.0;
  LatLng _currentRenderedPos = const LatLng(39.654760, 66.975830);
  double _currentRenderedHeading = 0.0;
  bool _isLocInitialized = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(_onAnimationTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUserLocation();
      ref.read(voiceCopilotProvider.notifier).startPassiveWakeWordListener(
        onWakeWordDetected: (query) {
          if (mounted) {
            VoiceAssistantOverlay.show(context);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    ref.read(voiceCopilotProvider.notifier).stopPassiveWakeWordListener();
    _animController.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    final t = Curves.linear.transform(_animController.value);
    final lat = _animStartPos.latitude + (_animTargetPos.latitude - _animStartPos.latitude) * t;
    final lng = _animStartPos.longitude + (_animTargetPos.longitude - _animStartPos.longitude) * t;
    final currentPos = LatLng(lat, lng);

    double diff = (_animTargetHeading - _animStartHeading) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    final currentHeading = (_animStartHeading + diff * t) % 360.0;

    setState(() {
      _currentRenderedPos = currentPos;
      _currentRenderedHeading = currentHeading;
      _currentCenter = currentPos;
    });

    if (_followUser) {
      _mapController.move(currentPos, _mapController.camera.zoom);
    }
  }

  void _onLocationReceived(UserLocation loc) {
    if (!_isLocInitialized) {
      _isLocInitialized = true;
      _currentRenderedPos = loc.latLng;
      _currentRenderedHeading = loc.heading;
      _animStartPos = loc.latLng;
      _animTargetPos = loc.latLng;
      _animStartHeading = loc.heading;
      _animTargetHeading = loc.heading;
      return;
    }

    _animStartPos = _currentRenderedPos;
    _animTargetPos = loc.latLng;
    _animStartHeading = _currentRenderedHeading;
    _animTargetHeading = loc.heading;

    _animController.forward(from: 0.0);
  }

  Future<void> _initUserLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final loc = await locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _currentCenter = loc.latLng;
      });
      _mapController.move(loc.latLng, 15.5);
      ref.read(radarListProvider.notifier).loadRadars(center: loc.latLng);
    }
  }

  Future<void> _recenterMap() async {
    HapticFeedback.selectionClick();
    setState(() => _followUser = true);
    final locationService = ref.read(locationServiceProvider);
    final loc = await locationService.getCurrentLocation();
    if (mounted) {
      setState(() => _currentCenter = loc.latLng);
      _mapController.move(loc.latLng, 16.0);
    }
  }

  void _onRadarTapped(RadarPoint radar) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RadarDetailSheet(
        radar: radar,
        onConfirm: () {
          ref.read(radarListProvider.notifier).confirmRadar(radar.id);
        },
      ),
    );
  }

  void _openQuickReport() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickReportSheet(
        currentLat: _currentCenter.latitude,
        currentLng: _currentCenter.longitude,
      ),
    );
  }

  void _showMapStyleDialog() {
    HapticFeedback.selectionClick();
    final currentStyle = ref.read(mapStyleProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final tr = AppLocalizations.of(context);
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.88),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    tr.tr('map_styles'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: MapStyle.values.map((style) {
                      final isSelected = style == currentStyle;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref.read(mapStyleProvider.notifier).state = style;
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.12),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  style == MapStyle.darkNavigation
                                      ? CupertinoIcons.moon_fill
                                      : style == MapStyle.osmStandard
                                          ? CupertinoIcons.sun_max_fill
                                          : CupertinoIcons.car_detailed,
                                  color: isSelected ? AppColors.primary : Colors.white70,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  style.getLocalizedName(tr),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleSimulation() async {
    HapticFeedback.mediumImpact();
    final isSimulating = ref.read(isSimulatingDriveProvider);
    final locationService = ref.read(locationServiceProvider);

    if (isSimulating) {
      locationService.stopDriveSimulation();
      ref.read(isSimulatingDriveProvider.notifier).state = false;
      setState(() => _simulatedRoutePoints = []);
    } else {
      ref.read(isSimulatingDriveProvider.notifier).state = true;
      setState(() => _followUser = true);

      // 1. Pick target radar ahead in Samarkand to demonstrate real warning
      final radars = ref.read(radarListProvider).value ?? [];
      LatLng targetRadar = const LatLng(39.658200, 66.962000); // Mirzo Ulug'bek radar
      if (radars.isNotEmpty) {
        double minD = double.infinity;
        for (final r in radars) {
          final d = LocationService.calculateDistance(
            _currentCenter.latitude,
            _currentCenter.longitude,
            r.lat,
            r.lng,
          );
          if (d > 300 && d < minD) {
            minD = d;
            targetRadar = LatLng(r.lat, r.lng);
          }
        }
      }

      // 2. Query real OpenStreetMap road geometry via OSRM
      List<LatLng> routePoints = [];
      try {
        final osrm = OsrmRoutingService();
        final routes = await osrm.calculateRealOsmRoutes(
          origin: _currentCenter,
          destination: targetRadar,
        );
        if (routes.isNotEmpty && routes.first.points.isNotEmpty) {
          routePoints = routes.first.points;
        }
      } catch (_) {}

      // 3. Fallback: Actual Samarkand road coordinates along Registon and Mirzo Ulug'bek avenue
      if (routePoints.isEmpty) {
        routePoints = const [
          LatLng(39.654760, 66.975830), // Registon Square
          LatLng(39.655180, 66.973950), // Registon ko'chasi
          LatLng(39.655750, 66.971480),
          LatLng(39.656520, 66.968120), // Mirzo Ulug'bek chorrahasi
          LatLng(39.657500, 66.964900), // Mirzo Ulug'bek shoh ko'chasi
          LatLng(39.658200, 66.962000), // Mirzo Ulug'bek Radar (70 km/h)
          LatLng(39.659100, 66.958200), // Continuing down avenue
          LatLng(39.659800, 66.954500),
        ];
      }

      setState(() {
        _simulatedRoutePoints = routePoints;
      });

      locationService.startDriveSimulation(
        waypoints: routePoints,
        targetSpeedKmh: 82.0, // 82 km/h triggers warning on 60/70 km/h radar!
        onFinished: () {
          ref.read(isSimulatingDriveProvider.notifier).state = false;
          if (mounted) {
            setState(() => _simulatedRoutePoints = []);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final isDark = ref.watch(settingsNotifierProvider).isDarkMode;
    final mapStyle = ref.watch(mapStyleProvider);
    final radarsAsync = ref.watch(radarListProvider);
    final alertState = ref.watch(radarAlertProvider);
    final isSimulating = ref.watch(isSimulatingDriveProvider);
    final parkingState = ref.watch(parkingZoneProvider);
    final placementState = ref.watch(mapPlacementProvider);
    final mapFilter = ref.watch(mapFilterProvider);

    final allRadars = radarsAsync.value ?? [];
    final allReports = ref.watch(reportListProvider).maybeWhen(
          data: (reports) => reports.where((r) => r.isVisibleOnMap).toList(),
          orElse: () => <UserReport>[],
        );

    // Filtered lists based on active category pill
    final filteredRadars = allRadars.where((r) {
      if (mapFilter == MapFilterType.all) return true;
      if (mapFilter == MapFilterType.radar) {
        return r.type == RadarType.mobile || r.type == RadarType.speedTrap;
      }
      if (mapFilter == MapFilterType.kamera) {
        return r.type == RadarType.stationary || r.type == RadarType.redLight;
      }
      return false;
    }).toList();

    final filteredReports = allReports.where((r) {
      if (mapFilter == MapFilterType.all) return true;
      if (mapFilter == MapFilterType.gai) {
        return r.type == ReportType.policePatrol;
      }
      return false;
    }).toList();

    final showParking = mapFilter == MapFilterType.all || mapFilter == MapFilterType.parkovka;

    ref.listen<AsyncValue<UserLocation>>(userLocationStreamProvider, (prev, next) {
      if (next.value != null) {
        _onLocationReceived(next.value!);
      }
    });

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Google Maps / Apple Maps Driving Map (Full Bleed Edge-to-Edge)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: isSimulating ? 17.2 : 14.8,
                minZoom: 3.0,
                maxZoom: 19.5,
              onTap: (tapPosition, point) {
                // Handle Map Placement Pin Drop (Radar, GAI, Kamera)
                if (placementState.isPlacing && placementState.activeType != null) {
                  HapticFeedback.mediumImpact();
                  final type = placementState.activeType!;
                  ref.read(mapPlacementProvider.notifier).cancelPlacing();
                  AddCustomObjectSheet.show(
                    context,
                    type: type,
                    lat: point.latitude,
                    lng: point.longitude,
                  );
                } else if (parkingState.isDrawingMode) {
                  HapticFeedback.selectionClick();
                  ref.read(parkingZoneProvider.notifier).addDraftPoint(point);
                }
              },
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() => _followUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: mapStyle.urlTemplate,
                subdomains: mapStyle.subdomains,
                userAgentPackageName: 'com.smartradar.navigator',
                maxNativeZoom: mapStyle.maxNativeZoom,
                maxZoom: 20,
              ),

              // Simulated Route Polyline (Shown during drive simulation)
              if (_simulatedRoutePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _simulatedRoutePoints,
                      strokeWidth: 5.0,
                      color: AppColors.primary.withOpacity(0.85),
                    ),
                  ],
                ),

              // Polygon Parking Zones Layer (Saved & Active Draft)
              PolygonLayer(
                polygons: [
                  // Saved Parking Polygons (Shown when parking is active/all)
                  if (showParking)
                    ...parkingState.savedZones.map((z) => Polygon(
                          points: z.points,
                          color: Color(z.colorValue).withOpacity(0.28),
                          borderColor: Color(z.colorValue),
                          borderStrokeWidth: 2.5,
                          isFilled: true,
                        )),
                  // Live Drawing Draft Polygon
                  if (parkingState.draftPoints.length >= 2)
                    Polygon(
                      points: parkingState.draftPoints,
                      color: const Color(0xFF00E5FF).withOpacity(0.35),
                      borderColor: const Color(0xFF00E5FF),
                      borderStrokeWidth: 3.0,
                      isFilled: true,
                    ),
                ],
              ),

              // 1. User Vehicle Marker Layer (Free rotation along heading)
              MarkerLayer(
                rotate: false,
                markers: [
                  Marker(
                    point: _currentRenderedPos,
                    width: 50,
                    height: 50,
                    child: Transform.rotate(
                      angle: _currentRenderedHeading * (math.pi / 180.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.6),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.location_north_fill,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Radars, Hazards, Parking Badges Layer (Always upright using rotate: true)
              MarkerLayer(
                rotate: true,
                markers: [
                  // Saved Parking Zone 🅿️ Center Badges
                  if (showParking)
                    ...parkingState.savedZones.map((zone) => Marker(
                          point: zone.centerPoint,
                          width: 38,
                          height: 38,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => ParkingZoneInfoSheet(zone: zone),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(zone.colorValue),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(zone.colorValue).withOpacity(0.6),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🅿️', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                        )),

                  // Live Drawing Draft Corner Vertices
                  ...parkingState.draftPoints.asMap().entries.map((entry) => Marker(
                        point: entry.value,
                        width: 26,
                        height: 26,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                            ),
                          ),
                        ),
                      )),

                  // Radar & Camera Pins (Mounted on a Stick / Pole)
                  ...filteredRadars.map((radar) {
                    final isStationary = radar.type == RadarType.stationary || radar.type == RadarType.redLight;
                    final markerColor = isStationary
                        ? AppColors.radarRed
                        : const Color(0xFFFF9500);

                    return Marker(
                      point: radar.latLng,
                      width: 64,
                      height: 56,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _onRadarTapped(radar),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Radar Head Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: markerColor, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: markerColor.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    radar.type == RadarType.mobile
                                        ? CupertinoIcons.dot_radiowaves_left_right
                                        : CupertinoIcons.camera_fill,
                                    color: markerColor,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3.5),
                                  Text(
                                    '${radar.speedLimit}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 2. Vertical Stick / Pole (Tayoqchasi)
                            Container(
                              width: 2.5,
                              height: 12,
                              decoration: BoxDecoration(
                                color: markerColor,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),

                            // 3. Anchor Base Dot (Poydevor nuqtasi)
                            Container(
                              width: 5.5,
                              height: 5.5,
                              decoration: BoxDecoration(
                                color: markerColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: markerColor.withOpacity(0.8),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Community GAI & Live Hazard Pins (Mounted on Pole / Glowing Badges)
                  ...filteredReports.map((report) {
                    final typeColor = report.type.color;
                    final isLevel5 = report.authorTrustLevel >= 5;
                    final isGai = report.type == ReportType.policePatrol;

                    return Marker(
                      point: report.latLng,
                      width: isGai ? 64 : 48,
                      height: isGai ? 56 : 48,
                      alignment: isGai ? Alignment.topCenter : Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withOpacity(0.95),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ReportItemCard(
                                    report: report,
                                    onUpvote: () {
                                      ref.read(reportListProvider.notifier).upvote(report.id);
                                    },
                                    onDownvote: () {
                                      ref.read(reportListProvider.notifier).downvote(report.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: isGai
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A).withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFF007AFF), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF007AFF).withOpacity(0.5),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(CupertinoIcons.shield_fill, color: Color(0xFF007AFF), size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'YPX',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 2.5,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  Container(
                                    width: 5.5,
                                    height: 5.5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.2),
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: typeColor, width: 2),
                                    ),
                                    child: Icon(report.type.icon, color: typeColor, size: 18),
                                  ),
                                  if (isLevel5)
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF34C759),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(CupertinoIcons.checkmark, color: Colors.black, size: 8),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Apple iOS Frosted Header HUD (Dynamic Search & Category Filter Pills)
          if (!parkingState.isDrawingMode && !placementState.isPlacing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Search & Destination Entry
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RoutePlanningScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A).withOpacity(0.80) : Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.14) : const Color(0xFFE5E5EA),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.search, color: isDark ? AppColors.primary : const Color(0xFF007AFF), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tr.tr('search'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 4 Interactive Category Filter Pills: GAI, Radar, Kamera, Parkovka
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // GAI Filter Pill
                            _buildQuickHeaderPill(
                              icon: CupertinoIcons.shield_fill,
                              label: 'GAI',
                              color: const Color(0xFF007AFF),
                              isDark: isDark,
                              isSelected: mapFilter == MapFilterType.gai,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref.read(mapFilterProvider.notifier).toggleFilter(MapFilterType.gai);
                              },
                            ),
                            const SizedBox(width: 6),

                            // Radar Filter Pill
                            _buildQuickHeaderPill(
                              icon: CupertinoIcons.dot_radiowaves_left_right,
                              label: 'Radar',
                              color: const Color(0xFFFF9500),
                              isDark: isDark,
                              isSelected: mapFilter == MapFilterType.radar,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref.read(mapFilterProvider.notifier).toggleFilter(MapFilterType.radar);
                              },
                            ),
                            const SizedBox(width: 6),

                            // Kamera Filter Pill
                            _buildQuickHeaderPill(
                              icon: CupertinoIcons.camera_fill,
                              label: 'Kamera',
                              color: const Color(0xFFFF3B30),
                              isDark: isDark,
                              isSelected: mapFilter == MapFilterType.kamera,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref.read(mapFilterProvider.notifier).toggleFilter(MapFilterType.kamera);
                              },
                            ),
                            const SizedBox(width: 6),

                            // Parkovka Filter Pill
                            _buildQuickHeaderPill(
                              icon: CupertinoIcons.placemark_fill,
                              label: 'Parkovka',
                              color: const Color(0xFF34C759),
                              isDark: isDark,
                              isSelected: mapFilter == MapFilterType.parkovka,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref.read(mapFilterProvider.notifier).toggleFilter(MapFilterType.parkovka);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Dynamic Island Proximity Radar Banner
                      if (alertState.isWarningActive && alertState.closestRadar != null)
                        NextRadarBanner(
                          radar: alertState.closestRadar!,
                          distanceMeters: alertState.distanceMeters,
                          isOverSpeed: alertState.isOverSpeed,
                          onTestVoice: () {
                            ref.read(radarAlertProvider.notifier).triggerTestAlert();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Map Placement HUD Banner (Active when placing Radar, GAI, or Camera)
          if (placementState.isPlacing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MapPlacementHud(),
            ),

          // 4. Parking Drawing HUD (Active when drawing mode is ON)
          if (parkingState.isDrawingMode)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ParkingDrawingHud(),
            ),

          // 4.5. Glowing Voice Copilot "Hey Radar" Floating Button
          Positioned(
            right: 16,
            bottom: 375,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                VoiceAssistantOverlay.show(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF00E5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.mic_fill, color: Colors.white, size: 17),
                        SizedBox(width: 6),
                        Text(
                          '«Hey Radar»',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 5. iOS Vertical Frosted Action Capsule (Right Side)
          Positioned(
            right: 16,
            bottom: 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.82),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🅿️ Parking Drawing Mode Toggle Button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.placemark_fill,
                          color: parkingState.isDrawingMode ? const Color(0xFF34C759) : AppColors.primary,
                          size: 22,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref.read(parkingZoneProvider.notifier).toggleDrawingMode();
                        },
                        tooltip: 'Parkovka Chizish',
                      ),
                      Divider(color: Colors.white.withOpacity(0.1), height: 12),

                      // Map Layer Toggle Button
                      IconButton(
                        icon: const Icon(CupertinoIcons.layers_alt_fill, color: AppColors.primary, size: 22),
                        onPressed: _showMapStyleDialog,
                        tooltip: 'Layers',
                      ),
                      Divider(color: Colors.white.withOpacity(0.1), height: 12),

                      // Simulation Drive Toggle
                      IconButton(
                        icon: Icon(
                          isSimulating ? CupertinoIcons.stop_circle_fill : CupertinoIcons.play_circle_fill,
                          color: isSimulating ? AppColors.radarRed : AppColors.primary,
                          size: 24,
                        ),
                        onPressed: _toggleSimulation,
                        tooltip: isSimulating ? tr.tr('stop_sim') : tr.tr('simulate_drive'),
                      ),
                      Divider(color: Colors.white.withOpacity(0.1), height: 12),

                      // Re-center Location Button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.location_fill,
                          color: _followUser ? AppColors.primary : Colors.white60,
                          size: 22,
                        ),
                        onPressed: _recenterMap,
                        tooltip: 'My Location',
                      ),
                      Divider(color: Colors.white.withOpacity(0.1), height: 12),

                      // Quick Report Hazard Button
                      IconButton(
                        icon: const Icon(CupertinoIcons.plus_circle_fill, color: AppColors.radarRed, size: 24),
                        onPressed: _openQuickReport,
                        tooltip: tr.tr('quick_report'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. Apple CarPlay Style Speedometer HUD (Bottom Left)
          Positioned(
            left: 16,
            bottom: 100,
            child: SpeedometerHud(
              currentSpeedKmh: alertState.currentSpeedKmh,
              speedLimitKmh: alertState.closestRadar?.speedLimit ?? 70,
              isWarningActive: alertState.isWarningActive,
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildQuickHeaderPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : (isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.92)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA)),
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? color.withOpacity(0.4) : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13.5, color: isSelected ? Colors.white : color),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
