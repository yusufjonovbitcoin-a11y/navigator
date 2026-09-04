import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/services/driving_behavior_service.dart';
import 'package:navigator/features/map_radar/domain/models/map_style.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_radar_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_style_provider.dart';
import 'package:navigator/main_screen_wrapper.dart';

class PotentialViolationItem {
  final String id;
  final String title;
  final String objectType; // 'radar' or 'kamera'
  final String streetName;
  final String landmark;
  final String timestamp;
  final double lat;
  final double lng;
  final int? speedLimit;
  final int? recordedSpeed;
  final int fineAmount;
  final String legalArticle;
  final String riskPercentage;
  final String description;
  final IconData icon;
  final Color color;

  const PotentialViolationItem({
    required this.id,
    required this.title,
    required this.objectType,
    required this.streetName,
    required this.landmark,
    required this.timestamp,
    required this.lat,
    required this.lng,
    this.speedLimit,
    this.recordedSpeed,
    required this.fineAmount,
    required this.legalArticle,
    required this.riskPercentage,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class PotentialViolationsSheet extends ConsumerWidget {
  final int periodIndex; // 0: Bugun, 1: Bu hafta, 2: Bu oy
  final bool isDark;

  const PotentialViolationsSheet({
    super.key,
    required this.periodIndex,
    required this.isDark,
  });

  static void show(BuildContext context, {required int periodIndex, required bool isDark}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PotentialViolationsSheet(
        periodIndex: periodIndex,
        isDark: isDark,
      ),
    );
  }

  List<PotentialViolationItem> _getViolations(WidgetRef ref) {
    final driving = ref.read(drivingBehaviorProvider);
    final events = driving.recentEvents.where((e) => e.type != DrivingEventType.smoothDriving).toList();

    if (events.isEmpty) {
      return [];
    }

    return events.map((e) {
      return PotentialViolationItem(
        id: 'viol_${e.timestamp.millisecondsSinceEpoch}',
        title: e.descriptionUz,
        objectType: 'telematics',
        streetName: 'Harakatlanish yo\'nalishi',
        landmark: 'G-kuch sensori: ${e.magnitude.toStringAsFixed(1)} m/s²',
        timestamp: '${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}',
        lat: 41.311081,
        lng: 69.240562,
        fineAmount: 0,
        legalArticle: 'Ichki telematika monitoringi',
        riskPercentage: 'Tezlik va manyovr nazorati',
        description: e.descriptionUz,
        icon: CupertinoIcons.exclamationmark_triangle_fill,
        color: const Color(0xFFFF9500),
      );
    }).toList();
  }

  static String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showViolationLocation(BuildContext context, WidgetRef ref, PotentialViolationItem v) {
    showLocation(context, ref, v, isDark: isDark);
  }

  static void showLocation(BuildContext context, WidgetRef ref, PotentialViolationItem v, {required bool isDark}) {
    HapticFeedback.mediumImpact();
    final mapStyle = ref.read(mapStyleProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: MediaQuery.of(sheetContext).size.height * 0.78,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                // Sheet Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: Color(0xFFFF3B30),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jarima qayd etilgan joy',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              v.streetName,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Interactive Map View
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(v.lat, v.lng),
                          initialZoom: 16.5,
                          minZoom: 10,
                          maxZoom: 19,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: mapStyle.urlTemplate,
                            fallbackUrl: mapStyle.fallbackUrl,
                            subdomains: mapStyle.subdomains,
                            userAgentPackageName: 'com.smartradar.navigator',
                            maxNativeZoom: mapStyle.maxNativeZoom,
                            maxZoom: 20,
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(v.lat, v.lng),
                                width: 110,
                                height: 80,
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Glowing Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFFFF3B30),
                                          width: 2.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF3B30).withOpacity(0.6),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            v.objectType == 'radar'
                                                ? CupertinoIcons.dot_radiowaves_left_right
                                                : CupertinoIcons.camera_fill,
                                            color: const Color(0xFFFF3B30),
                                            size: 13,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            v.recordedSpeed != null
                                                ? '${v.recordedSpeed} km/s'
                                                : 'Kamera',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Pole
                                    Container(
                                      width: 2.5,
                                      height: 14,
                                      color: const Color(0xFFFF3B30),
                                    ),
                                    // Anchor Dot
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF3B30),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF3B30).withOpacity(0.8),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Location coordinates chip (top left)
                      Positioned(
                        top: 12,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.88),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            '📍 ${v.lat.toStringAsFixed(4)}, ${v.lng.toStringAsFixed(4)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Details & Action Card
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.landmark,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qayd etilgan vaqt: ${v.timestamp}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9500).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '~${_formatMoney(v.fineAmount)} so\'m',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF9500),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Button: Asosiy xaritada ochish
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            // Close location modal
                            Navigator.pop(sheetContext);
                            // Close violations sheet
                            Navigator.pop(context);
                            // Focus target coordinate on main map
                            ref.read(mapTargetFocusProvider.notifier).state = LatLng(v.lat, v.lng);
                            // Switch to Map tab
                            ref.read(currentTabProvider.notifier).state = 0;
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.compass, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Asosiy xaritada ko\'rish',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0);

    final violations = _getViolations(ref);
    final radarCount = violations.where((v) => v.objectType == 'radar').length;
    final cameraCount = violations.where((v) => v.objectType == 'kamera').length;


    final periodLabel = periodIndex == 0
        ? 'Bugun'
        : periodIndex == 1
            ? 'Bu hafta'
            : 'Bu oy';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withOpacity(0.96) : const Color(0xFFF8FAFC).withOpacity(0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Header Row with Title and Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.exclamationmark_shield_fill,
                      color: Color(0xFFFF3B30),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ehtimoliy Jarimalar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          '$periodLabel: $radarCount ta radar, $cameraCount ta kamera',
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.xmark, size: 16, color: subtextColor),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                children: [

                  if (violations.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759).withOpacity(0.14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.checkmark_shield_fill,
                                color: Color(0xFF34C759),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Qoidabuzarliklar mavjud emas',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ushbu davrda barcha tezlik va yo\'l harakati qoidalariga namunali rioya qilindi. Jarima xavfi aniqlanmadi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: subtextColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'QAYD ETILGAN HOLATLAR RO\'YXATI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: subtextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...violations.map((v) => _buildViolationCard(context, ref, v, cardBg, borderColor, textColor, subtextColor)),
                  ],

                  const SizedBox(height: 12),

                  // Legal Disclaimer Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.info_circle, size: 16, color: subtextColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ushbu ma\'lumotlar harakat davomida radar va kameralar oldida qayd etilgan tezlik hamda harakat tahliliga asoslangan. Rasmiy jarima mavjudligini YHXBB tizimi yoki SMS orqali tekshiring.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: subtextColor,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationCard(
    BuildContext context,
    WidgetRef ref,
    PotentialViolationItem v,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    final isSpeed = v.recordedSpeed != null && v.speedLimit != null;
    final diff = isSpeed ? (v.recordedSpeed! - v.speedLimit!) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showViolationLocation(context, ref, v),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Icon + Title + Fine Amount
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: v.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(v.icon, color: v.color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        v.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      '~${_formatMoney(v.fineAmount)} so\'m',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFFF9F0A) : const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Row 2: Location & Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.location_solid, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              v.streetName,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: subtextColor,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      v.timestamp,
                      style: TextStyle(
                        fontSize: 11,
                        color: subtextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Row 3: Speed / Article Tag + Risk Badge + Map Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isSpeed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${v.speedLimit} km/s',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Icon(CupertinoIcons.arrow_right, size: 9, color: subtextColor),
                            ),
                            Text(
                              '${v.recordedSpeed} km/s',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFF3B30),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+$diff',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF3B30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          v.legalArticle,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: subtextColor,
                          ),
                        ),
                      ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            v.riskPercentage,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.map_pin_ellipse,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Xaritada',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
