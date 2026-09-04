import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/core/services/yandex_geocoding_service.dart';
import 'package:navigator/core/services/osm_geocoding_service.dart';
import 'package:navigator/features/map_radar/domain/models/map_style.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_style_provider.dart';
import 'package:navigator/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:navigator/features/navigation/presentation/screens/active_navigation_screen.dart';
import 'package:navigator/features/navigation/presentation/widgets/route_card.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class RoutePlanningScreen extends ConsumerStatefulWidget {
  const RoutePlanningScreen({super.key});

  @override
  ConsumerState<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends ConsumerState<RoutePlanningScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final YandexGeocodingService _geocodingService = YandexGeocodingService();

  List<OsmPlace> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = ref.read(userLocationStreamProvider).value;
      if (loc != null) {
        ref.read(routePlanningProvider.notifier).setOrigin(loc.latLng);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isSearching = true);
      final loc = ref.read(userLocationStreamProvider).value;
      final results = await _geocodingService.searchPlaces(
        query,
        userLat: loc?.latLng.latitude,
        userLng: loc?.latLng.longitude,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectOsmPlace(OsmPlace place) async {
    HapticFeedback.selectionClick();
    _searchController.clear();
    setState(() => _searchResults = []);
    FocusScope.of(context).unfocus();

    LatLng? target;
    String targetName = place.name;

    if (place.lat != 0.0 && place.lng != 0.0) {
      target = place.latLng;
    } else if (place.uri != null) {
      final resolved = await _geocodingService.resolveUri(place.uri!);
      if (resolved != null) {
        target = resolved.latLng;
        if (resolved.name.isNotEmpty) targetName = resolved.name;
      }
    }

    if (target == null) {
      final fallbackQuery = place.displayName.isNotEmpty ? place.displayName : place.name;
      final fallbackList = await _geocodingService.searchPlaces(fallbackQuery);
      for (final p in fallbackList) {
        if (p.lat != 0.0 && p.lng != 0.0) {
          target = p.latLng;
          targetName = p.name;
          break;
        }
      }
    }

    if (target != null && mounted) {
      ref.read(routePlanningProvider.notifier).planRoute(
            customDest: target,
            customDestName: targetName,
          );

      _mapController.move(target, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final state = ref.watch(routePlanningProvider);
    final mapStyle = ref.watch(mapStyleProvider);
    final selectedRoute = state.selectedRoute;

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);
    final brandColor = isDark ? AppColors.primary : const Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          tr.tr('plan_route'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: textColor,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 1. Destination Input and OpenStreetMap Search Bar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E5EA),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // iOS Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: tr.tr('search_destination'),
                          hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                          prefixIcon: Icon(CupertinoIcons.search, color: brandColor, size: 18),
                          suffixIcon: _isSearching
                              ? CupertinoActivityIndicator(color: brandColor, radius: 8)
                              : _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(CupertinoIcons.clear_circled_solid, size: 16, color: subtextColor),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchResults = []);
                                      },
                                    )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),

                    // Live OSM Search Results Dropdown
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA),
                          ),
                          itemBuilder: (context, idx) {
                            final place = _searchResults[idx];
                            return ListTile(
                              dense: true,
                              leading: const Icon(CupertinoIcons.location_fill, color: AppColors.radarRed, size: 18),
                              title: Text(
                                place.name,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              subtitle: Text(
                                place.subtitle ?? place.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: subtextColor),
                              ),
                              onTap: () => _selectOsmPlace(place),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    // Selected Destination Indicator (if any)
                    if (state.destination != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E5EA),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.flag_fill, color: Color(0xFF34C759), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.destinationName ?? 'Tanlangan manzil',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _searchController.clear();
                                ref.read(routePlanningProvider.notifier).clearDestination();
                              },
                              child: Icon(CupertinoIcons.clear_circled_solid, size: 16, color: subtextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 2. Real OpenStreetMap Preview with Route Polylines
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: selectedRoute != null && selectedRoute.points.isNotEmpty
                        ? selectedRoute.points.first
                        : state.origin,
                    initialZoom: 14.0,
                    minZoom: 3.0,
                    maxZoom: 19.5,
                    onTap: (tapPosition, point) {
                      HapticFeedback.selectionClick();
                      ref.read(routePlanningProvider.notifier).planRoute(
                            customDest: point,
                            customDestName: '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                          );
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

                    // Polylines Layer
                    if (selectedRoute != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: selectedRoute.points,
                            strokeWidth: 6.0,
                            color: selectedRoute.isSafest ? const Color(0xFF34C759) : brandColor,
                          ),
                        ],
                      ),

                    // Start and End Markers
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.origin,
                          width: 32,
                          height: 32,
                          child: const Icon(CupertinoIcons.circle_fill, color: Color(0xFF34C759), size: 18),
                        ),
                        if (state.destination != null)
                          Marker(
                            point: state.destination!,
                            width: 40,
                            height: 40,
                            child: const Icon(CupertinoIcons.location_solid, color: Color(0xFFFF3B30), size: 32),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Route Comparison Selection (Fastest vs Safest)
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A).withOpacity(0.92) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.14) : const Color(0xFFE5E5EA),
                      ),
                    ),
                  ),
                  child: state.isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoActivityIndicator(color: brandColor, radius: 14),
                              const SizedBox(height: 12),
                              Text(
                                'Marshrut hisoblanmoqda...',
                                style: TextStyle(fontSize: 14, color: subtextColor),
                              ),
                            ],
                          ),
                        )
                      : state.destination == null || state.availableRoutes.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.map_pin_ellipse, size: 48, color: brandColor.withOpacity(0.4)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Manzil tanlanmagan',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Qidiruv orqali manzilni yozing yoki xarita ustiga bosib manzilni belgilang',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, color: subtextColor),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: state.availableRoutes.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, idx) {
                                      final route = state.availableRoutes[idx];
                                      final isSelected = selectedRoute?.id == route.id;
                                      return RouteCard(
                                        route: route,
                                        isSelected: isSelected,
                                        onTap: () {
                                          ref.read(routePlanningProvider.notifier).selectRoute(route);
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Start Navigation Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    color: selectedRoute?.isSafest == true
                                        ? const Color(0xFF34C759)
                                        : brandColor,
                                    borderRadius: BorderRadius.circular(18),
                                    onPressed: selectedRoute == null
                                        ? null
                                        : () {
                                            HapticFeedback.mediumImpact();
                                            ref.read(activeNavProvider.notifier).startNavigation(selectedRoute);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const ActiveNavigationScreen(),
                                              ),
                                            );
                                          },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(CupertinoIcons.arrow_up_right_diamond_fill, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          tr.tr('start_navigation'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
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
        ],
      ),
    );
  }
}
