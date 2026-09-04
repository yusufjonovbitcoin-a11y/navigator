import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;
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
import 'package:navigator/features/reports/presentation/providers/pothole_placement_provider.dart';
import 'package:navigator/features/reports/presentation/providers/report_adjustment_provider.dart';
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

  // Multiradarni ustiga bosib ekrandan qo'lni uzmasdan siljitish holati
  Offset? _multiradarDragScreenPos;
  bool _isDraggingMultiradar = false;

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
    ref.read(mapFilterProvider.notifier).clear();
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
    final isDark = ref.read(settingsNotifierProvider).isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final tr = AppLocalizations.of(ctx);
        final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtextColor = isDark ? Colors.white60 : const Color(0xFF64748B);

        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeStyle = ref.watch(mapStyleProvider);
            final activeFilter = ref.watch(mapFilterProvider);

            final bottomInset = MediaQuery.of(context).padding.bottom;

            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.55 : 0.14),
                    blurRadius: 30,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset > 0 ? bottomInset + 12 : 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Header with Title & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr.tr('map_type'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 16,
                            color: subtextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3 Google Maps Style Cards (Default, Satellite, Dark)
                  Row(
                    children: [
                      // 1. Standart / По умолчанию
                      _buildGoogleMapStyleCard(
                        style: MapStyle.osmStandard,
                        title: tr.tr('osm_standard'),
                        isSelected: activeStyle == MapStyle.osmStandard,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(mapStyleProvider.notifier).state = MapStyle.osmStandard;
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(width: 12),

                      // 2. Yo'ldosh / Спутник
                      _buildGoogleMapStyleCard(
                        style: MapStyle.satellite,
                        title: tr.tr('satellite'),
                        isSelected: activeStyle == MapStyle.satellite,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(mapStyleProvider.notifier).state = MapStyle.satellite;
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(width: 12),

                      // 3. Tungi / Тёмная
                      _buildGoogleMapStyleCard(
                        style: MapStyle.darkNavigation,
                        title: tr.tr('osm_dark'),
                        isSelected: activeStyle == MapStyle.darkNavigation,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(mapStyleProvider.notifier).state = MapStyle.darkNavigation;
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMapTypePreview(MapStyle style) {
    switch (style) {
      case MapStyle.osmStandard:
        return ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: CustomPaint(
            painter: GoogleMapsStandardPainter(),
            size: Size.infinite,
          ),
        );

      case MapStyle.satellite:
        return ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: CustomPaint(
            painter: GoogleMapsSatellitePainter(),
            size: Size.infinite,
          ),
        );

      case MapStyle.darkNavigation:
        return ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: CustomPaint(
            painter: GoogleMapsDarkPainter(),
            size: Size.infinite,
          ),
        );
    }
  }

  Widget _buildGoogleMapStyleCard({
    required MapStyle style,
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    const activeBorderColor = Color(0xFF1A73E8);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? activeBorderColor : (isDark ? Colors.white12 : const Color(0xFFDADCE0)),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeBorderColor.withOpacity(0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildMapTypePreview(style),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: activeBorderColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? activeBorderColor
                    : (isDark ? Colors.white70 : const Color(0xFF3C4043)),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
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
    final potholePlacement = ref.watch(potholePlacementProvider);
    final adjustmentState = ref.watch(reportAdjustmentProvider);
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
      if (r.type == ReportType.accident ||
          r.type == ReportType.trafficJam ||
          r.type == ReportType.roadwork) {
        return false;
      }
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

    ref.listen<LatLng?>(mapTargetFocusProvider, (prev, next) {
      if (next != null) {
        setState(() => _followUser = false);
        _mapController.move(next, 16.8);
        ref.read(mapTargetFocusProvider.notifier).state = null;
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8ECE9),
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
                interactionOptions: InteractionOptions(
                  flags: _isDraggingMultiradar
                      ? InteractiveFlag.none
                      : InteractiveFlag.all,
                ),
              onTap: (tapPosition, point) {
                // Opasnaya yama: tayoqchani bosilgan joyga to'g'rilash
                if (potholePlacement.isPlacing) {
                  HapticFeedback.selectionClick();
                  _mapController.move(point, _mapController.camera.zoom);
                  return;
                }

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
                            // 1. Radar / Camera Head Badge
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
                                    isStationary
                                        ? CupertinoIcons.camera_fill
                                        : CupertinoIcons.dot_radiowaves_left_right,
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
                  ...filteredReports
                      .where((r) => !(adjustmentState.isActive &&
                          adjustmentState.reportId == r.id &&
                          adjustmentState.remainingMoves > 0))
                      .map((report) {
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
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF34C759),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.checkmark_alt,
                                          color: Colors.white,
                                          size: 8,
                                        ),
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

          // Draggable Multiradar Overlay (Ustiga bosib turib ekrandan qo'lni uzmasdan siljitish)
          if (adjustmentState.isActive && adjustmentState.remainingMoves > 0)
            _buildDraggableMultiradarOverlay(adjustmentState),

          // Opasnaya yama: xaritada markaziy tayoqcha
          if (potholePlacement.isPlacing)
            _buildPotholeCenterPin(),

          // 2. Apple iOS Frosted Header HUD (Dynamic Search & Category Filter Pills)
          if (!parkingState.isDrawingMode && !placementState.isPlacing && !potholePlacement.isPlacing)
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

          // 2.5. Google Maps Style Standalone Floating Layers Button (Top Right)
          if (!parkingState.isDrawingMode && !placementState.isPlacing && !potholePlacement.isPlacing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 106,
              right: 16,
              child: GestureDetector(
                onTap: _showMapStyleDialog,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.square_stack_3d_up_fill,
                    color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                    size: 21,
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

          // 3.5. Opasnaya yama Placement HUD (Tepada saqlash tugmasi)
          if (potholePlacement.isPlacing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildPotholePlacementTopHud(),
            ),

          // 4. Parking Drawing HUD (Active when drawing mode is ON)
          if (parkingState.isDrawingMode)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ParkingDrawingHud(),
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

          // 6. Apple CarPlay Style Speedometer HUD (Top Left)
          // Faqat avtomobil 10 km/soat va undan yuqori tezlikda harakatlanganda ko'rinadi
          if (alertState.currentSpeedKmh >= 10)
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 106,
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

  Widget _buildDraggableMultiradarOverlay(ReportAdjustmentState adjustmentState) {
    math.Point<double> screenPoint;
    try {
      screenPoint = _mapController.camera.latLngToScreenPoint(adjustmentState.currentPos);
    } catch (_) {
      return const SizedBox.shrink();
    }

    final isDragging = _isDraggingMultiradar;
    final currentOffset = _multiradarDragScreenPos ?? Offset(screenPoint.x, screenPoint.y);

    final isGai = adjustmentState.type == ReportType.policePatrol;
    final primaryColor = isGai ? const Color(0xFF007AFF) : const Color(0xFFFF3366);
    final gradientColors = isGai
        ? [const Color(0xFF0A2540), const Color(0xFF0066EE)]
        : [const Color(0xFF2A0845), const Color(0xFF6441A5)];
    final label = isGai ? 'Патруль ДПС' : 'Мультирадар';
    final icon = isGai ? CupertinoIcons.shield_fill : CupertinoIcons.camera_fill;

    // Hit target dimensions (large touch hitbox so user can easily grab it)
    const double targetWidth = 140.0;
    const double targetHeight = 120.0;
    final double liftY = isDragging ? 50.0 : 0.0;

    return Positioned(
      left: currentOffset.dx - (targetWidth / 2),
      top: currentOffset.dy - targetHeight + 20 - liftY,
      width: targetWidth,
      height: targetHeight + liftY,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          HapticFeedback.selectionClick();
          setState(() {
            _isDraggingMultiradar = true;
            _multiradarDragScreenPos = details.globalPosition;
          });
          ref.read(reportAdjustmentProvider.notifier).setIsDragging(true);
        },
        onPanUpdate: (details) {
          setState(() {
            _multiradarDragScreenPos = details.globalPosition;
          });
        },
        onPanEnd: (details) async {
          final dropPos = _multiradarDragScreenPos;
          setState(() {
            _isDraggingMultiradar = false;
            _multiradarDragScreenPos = null;
          });
          ref.read(reportAdjustmentProvider.notifier).setIsDragging(false);

          if (dropPos != null) {
            try {
              final newLatLng = _mapController.camera.pointToLatLng(
                math.Point(dropPos.dx, dropPos.dy),
              );

              HapticFeedback.mediumImpact();
              ref.read(reportAdjustmentProvider.notifier).updateCurrentPos(newLatLng);
              ref.read(reportListProvider.notifier).updateReportLocationOptimistic(
                    id: adjustmentState.reportId,
                    lat: newLatLng.latitude,
                    lng: newLatLng.longitude,
                  );

              await ref.read(reportListProvider.notifier).updateReportLocation(
                    id: adjustmentState.reportId,
                    lat: newLatLng.latitude,
                    lng: newLatLng.longitude,
                  );

              final isDone = ref.read(reportAdjustmentProvider.notifier).commitMove();
              if (isDone) {
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    ref.read(reportAdjustmentProvider.notifier).finish();
                  }
                });
              }
            } catch (e) {
              debugPrint('Error projecting drag drop point: $e');
            }
          }
        },
        onPanCancel: () {
          setState(() {
            _isDraggingMultiradar = false;
            _multiradarDragScreenPos = null;
          });
          ref.read(reportAdjustmentProvider.notifier).setIsDragging(false);
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // While dragging: crosshair dot on the exact road point under finger
            if (isDragging)
              Positioned(
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: liftY - 4,
                      color: primaryColor.withOpacity(0.7),
                    ),
                  ],
                ),
              ),

            // The Radar Marker Badge
            Positioned(
              bottom: isDragging ? liftY + 12 : 12,
              child: AnimatedScale(
                scale: isDragging ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDragging
                                ? primaryColor.withOpacity(0.7)
                                : Colors.black.withOpacity(0.4),
                            blurRadius: isDragging ? 16 : 8,
                            offset: Offset(0, isDragging ? 6 : 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Needle pointing to road
                    if (!isDragging) ...[
                      Container(
                        width: 2.2,
                        height: 7,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotholeCenterPin() {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC084FC), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.55),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      color: Color(0xFFFBBF24),
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Опасная яма',
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

              // Tayoqcha (vertical pole)
              Container(
                width: 2.4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFC084FC),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

              // Point at the road
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPotholePlacementTopHud() {
    final isDark = ref.watch(settingsNotifierProvider).isDarkMode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withOpacity(0.94) : Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cancel button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(potholePlacementProvider.notifier).cancelPlacing();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 16,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and instruction
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Опасная яма',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Tayoqchani belgilangan joyga olib boring',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // "Saqlash" button (Tepada saqlash tugmasi!)
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final centerPoint = _mapController.camera.center;
                      ref.read(potholePlacementProvider.notifier).cancelPlacing();

                      await ref.read(reportListProvider.notifier).createReport(
                            type: ReportType.pothole,
                            lat: centerPoint.latitude,
                            lng: centerPoint.longitude,
                            address: 'Chuqurlik (${centerPoint.latitude.toStringAsFixed(4)}, ${centerPoint.longitude.toStringAsFixed(4)})',
                          );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: const Color(0xFF0F172A),
                            elevation: 6,
                            content: const Row(
                              children: [
                                Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Color(0xFF10B981), size: 22),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Опасная яма joylandi va saqlandi',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            'Saqlash',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleMapsStandardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base land: Google Maps cream
    final landPaint = Paint()..color = const Color(0xFFF1EFE8);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(13)), landPaint);

    // 2. Water (curved river/bay on top-right & right)
    final waterPaint = Paint()..color = const Color(0xFFA5C9EB)..style = PaintingStyle.fill;
    final waterPath = Path()
      ..moveTo(size.width * 0.65, 0)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.4, size.width, size.height * 0.55)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // 3. Green park area (bottom-left)
    final parkPaint = Paint()..color = const Color(0xFFC6E7D2)..style = PaintingStyle.fill;
    final parkPath = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.15, size.width * 0.38, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.75, 0, size.height * 0.65)
      ..close();
    canvas.drawPath(parkPath, parkPaint);

    // 4. City street grid (white roads)
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width * 0.75, size.height * 0.3), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), streetPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height), streetPaint);

    // 5. Google Maps Main Highway (Yellow with orange edge)
    final highwayCasing = Paint()
      ..color = const Color(0xFFF1C453)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    final highwayPaint = Paint()
      ..color = const Color(0xFFFBD471)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke;

    final highwayPath = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(size.width * 0.35, size.height * 0.5, size.width * 0.55, size.height * 0.45, size.width, size.height * 0.35);

    canvas.drawPath(highwayPath, highwayCasing);
    canvas.drawPath(highwayPath, highwayPaint);

    // 6. Navigation Red Pin or Location Point
    final pinPaint = Paint()..color = const Color(0xFFEA4335);
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.46), 4.5, pinPaint);
    final pinInner = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.46), 2.0, pinInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoogleMapsSatellitePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base terrain gradient (lush forest green & agricultural shades)
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1B3D22), Color(0xFF284E2D), Color(0xFF1E3520)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(13)), bgPaint);

    // 2. Agricultural field patchwork
    final field1 = Paint()..color = const Color(0xFF335836).withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.08, size.height * 0.12, size.width * 0.28, size.height * 0.32), field1);

    final field2 = Paint()..color = const Color(0xFF4A4B2E).withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.05, size.height * 0.55, size.width * 0.32, size.height * 0.35), field2);

    // 3. Deep ocean / coastline (right side)
    final oceanPaint = Paint()..color = const Color(0xFF0C2438)..style = PaintingStyle.fill;
    final coastPath = Path()
      ..moveTo(size.width * 0.62, 0)
      ..quadraticBezierTo(size.width * 0.68, size.height * 0.45, size.width, size.height * 0.62)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(coastPath, oceanPaint);

    // Sand shoreline
    final sandPaint = Paint()
      ..color = const Color(0xFF8A8265).withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final sandPath = Path()
      ..moveTo(size.width * 0.62, 0)
      ..quadraticBezierTo(size.width * 0.68, size.height * 0.45, size.width, size.height * 0.62);
    canvas.drawPath(sandPath, sandPaint);

    // 4. White aerial roads and bridge crossing ocean
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final bridgePath = Path()
      ..moveTo(0, size.height * 0.48)
      ..cubicTo(size.width * 0.4, size.height * 0.48, size.width * 0.65, size.height * 0.4, size.width, size.height * 0.32);
    canvas.drawPath(bridgePath, roadPaint);

    // Secondary aerial grid
    final gridRoad = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), gridRoad);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width * 0.75, size.height * 0.75), gridRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoogleMapsDarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark charcoal/slate navigation background
    final landPaint = Paint()..color = const Color(0xFF181E29);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(13)), landPaint);

    // 2. Dark navy water bay
    final waterPaint = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill;
    final waterPath = Path()
      ..moveTo(size.width * 0.65, 0)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.4, size.width, size.height * 0.55)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // 3. Dark forest park
    final parkPaint = Paint()..color = const Color(0xFF1E2A38)..style = PaintingStyle.fill;
    final parkPath = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.15, size.width * 0.38, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.75, 0, size.height * 0.65)
      ..close();
    canvas.drawPath(parkPath, parkPaint);

    // 4. Subtle dark streets grid
    final streetPaint = Paint()
      ..color = const Color(0xFF283447)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width * 0.75, size.height * 0.3), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), streetPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height), streetPaint);

    // 5. Glowing Neon Cyan Navigation Route
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.4)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final routePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(size.width * 0.35, size.height * 0.5, size.width * 0.55, size.height * 0.45, size.width, size.height * 0.35);

    canvas.drawPath(routePath, glowPaint);
    canvas.drawPath(routePath, routePaint);

    // 6. Cyan GPS Navigation Arrow
    final arrowPaint = Paint()..color = Colors.white;
    final arrowPath = Path()
      ..moveTo(size.width * 0.48, size.height * 0.4)
      ..lineTo(size.width * 0.53, size.height * 0.52)
      ..lineTo(size.width * 0.48, size.height * 0.48)
      ..lineTo(size.width * 0.43, size.height * 0.52)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
