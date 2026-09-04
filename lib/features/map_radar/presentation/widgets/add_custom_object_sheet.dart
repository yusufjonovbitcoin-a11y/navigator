import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_placement_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_radar_provider.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:navigator/main_screen_wrapper.dart';

enum CustomObjectType {
  gai,
  radar,
  kamera,
}

class AddCustomObjectSheet extends ConsumerStatefulWidget {
  final CustomObjectType initialType;
  final double currentLat;
  final double currentLng;

  const AddCustomObjectSheet({
    super.key,
    required this.initialType,
    required this.currentLat,
    required this.currentLng,
  });

  static void show(
    BuildContext context, {
    required CustomObjectType type,
    required double lat,
    required double lng,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCustomObjectSheet(
        initialType: type,
        currentLat: lat,
        currentLng: lng,
      ),
    );
  }

  @override
  ConsumerState<AddCustomObjectSheet> createState() => _AddCustomObjectSheetState();
}

class _AddCustomObjectSheetState extends ConsumerState<AddCustomObjectSheet> {
  int _selectedSpeedLimit = 70;
  final Set<String> _selectedFeatures = <String>{};
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  final List<int> _speedLimits = [30, 40, 50, 60, 70, 80, 90, 100, 110, 120];

  static const _features = [
    (
      id: 'kamar',
      label: 'Kamar',
      subtitle: 'Xavfsizlik kamari',
      icon: Icons.airline_seat_recline_normal_rounded,
      color: Color(0xFF10B981),
    ),
    (
      id: 'telefon',
      label: 'Telefon',
      subtitle: 'Rulda telefon',
      icon: Icons.phone_iphone_rounded,
      color: Color(0xFF6366F1),
    ),
    (
      id: 'palasa',
      label: 'Palasa',
      subtitle: 'Yo\'l chizig\'i / Polosa',
      icon: Icons.alt_route_rounded,
      color: Color(0xFFF59E0B),
    ),
    (
      id: 'svetofor',
      label: 'Svetofor',
      subtitle: 'Qizil chiroq',
      icon: Icons.traffic_rounded,
      color: Color(0xFFEF4444),
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    ReportType reportType;
    String defaultNote;

    final now = DateTime.now();
    final customId = 'custom_${widget.initialType.name}_${now.millisecondsSinceEpoch}';

    final featureNames = _selectedFeatures.map((f) {
      switch (f) {
        case 'kamar':
          return 'Kamar';
        case 'telefon':
          return 'Telefon';
        case 'palasa':
          return 'Palasa';
        case 'svetofor':
          return 'Svetofor';
        default:
          return f;
      }
    }).toList();

    final featureStr = featureNames.isNotEmpty ? ' [${featureNames.join(', ')}]' : '';
    final noteText = _noteController.text.trim();

    switch (widget.initialType) {
      case CustomObjectType.gai:
        reportType = ReportType.policePatrol;
        defaultNote = 'YPX / GAI patruli (${noteText.isEmpty ? 'faol' : noteText})';
        break;
      case CustomObjectType.radar:
        reportType = ReportType.stationaryRadar;
        defaultNote = 'Radar - $_selectedSpeedLimit km/soat$featureStr${noteText.isNotEmpty ? ' ($noteText)' : ''}';

        final titleStr = featureNames.isNotEmpty
            ? 'Radar ($_selectedSpeedLimit km/s, ${featureNames.join(', ')})'
            : 'Radar ($_selectedSpeedLimit km/soat)';

        final radarPoint = RadarPoint(
          id: customId,
          lat: widget.currentLat,
          lng: widget.currentLng,
          type: RadarType.mobile,
          speedLimit: _selectedSpeedLimit,
          confirmedCount: 3,
          lastConfirmed: now,
          title: titleStr,
          address: 'Toshkent shahar koordinatasi',
          features: _selectedFeatures.toList(),
        );
        ref.read(radarListProvider.notifier).addCustomRadar(radarPoint);
        break;
      case CustomObjectType.kamera:
        reportType = ReportType.stationaryRadar;
        defaultNote = 'Kamera - $_selectedSpeedLimit km/soat$featureStr${noteText.isNotEmpty ? ' ($noteText)' : ''}';

        final titleStr = featureNames.isNotEmpty
            ? 'Kamera (${featureNames.join(', ')})'
            : 'Kamera ($_selectedSpeedLimit km/soat)';

        final cameraPoint = RadarPoint(
          id: customId,
          lat: widget.currentLat,
          lng: widget.currentLng,
          type: RadarType.stationary,
          speedLimit: _selectedSpeedLimit,
          confirmedCount: 5,
          lastConfirmed: now,
          title: titleStr,
          address: 'Toshkent shahar koordinatasi',
          features: _selectedFeatures.toList(),
        );
        ref.read(radarListProvider.notifier).addCustomRadar(cameraPoint);
        break;
    }

    // Submit community report so it persists in the feed as well
    final success = await ref.read(reportListProvider.notifier).submitReport(
          type: reportType,
          lat: widget.currentLat,
          lng: widget.currentLng,
          note: defaultNote,
          address: 'Toshkent koordinatasi: (${widget.currentLat.toStringAsFixed(4)}, ${widget.currentLng.toStringAsFixed(4)})',
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();

    // Directly navigate to Map screen to see the newly placed pin!
    ref.read(currentTabProvider.notifier).state = 0;

    if (success) {
      final title = widget.initialType == CustomObjectType.gai
          ? 'YPX / GAI posti'
          : widget.initialType == CustomObjectType.radar
              ? 'Radar'
              : 'Statsionar kamera';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('$title xaritaga muvaffaqiyatli belgilandi! (+15 Karma)'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsNotifierProvider).isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA);
    final inputBg = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7);

    final activeColor = widget.initialType == CustomObjectType.gai
        ? const Color(0xFF007AFF)
        : widget.initialType == CustomObjectType.radar
            ? const Color(0xFFFF9500)
            : const Color(0xFFFF3B30);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.initialType == CustomObjectType.gai
                          ? CupertinoIcons.shield_fill
                          : widget.initialType == CustomObjectType.radar
                              ? CupertinoIcons.dot_radiowaves_left_right
                              : CupertinoIcons.camera_fill,
                      color: activeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.initialType == CustomObjectType.gai
                              ? 'GAI / YPX Patruli Qo\'shish'
                              : widget.initialType == CustomObjectType.radar
                                  ? 'Radar Qo\'shish'
                                  : 'Kamera Qo\'shish',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          widget.initialType == CustomObjectType.gai
                              ? 'Ayni joylashuvingizga YPX patruli belgilang'
                              : widget.initialType == CustomObjectType.radar
                                  ? 'Tezlik, kamar, telefon va boshqa nazoratlar'
                                  : 'Kamar, telefon, palasa va svetofor nazorati',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Location preview + Map Pin Pick button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.location_solid, color: activeColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '(${widget.currentLat.toStringAsFixed(4)}, ${widget.currentLng.toStringAsFixed(4)})',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        ref.read(mapPlacementProvider.notifier).startPlacing(widget.initialType);
                        ref.read(currentTabProvider.notifier).state = 0;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: activeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.map_pin_ellipse, color: activeColor, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              'Xaritadan tanlash',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: activeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 1. Speed Limit Selector (Only for Radar & Kamera)
              if (widget.initialType != CustomObjectType.gai) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ruxsat etilgan tezlik',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    Text(
                      '$_selectedSpeedLimit km/soat',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: activeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _speedLimits.map((speed) {
                      final isSelected = _selectedSpeedLimit == speed;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedSpeedLimit = speed);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? activeColor : inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? activeColor : borderColor,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: activeColor.withOpacity(0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              '$speed',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // 2. Additional violations multi-select (For Radar & Kamera)
              if (widget.initialType != CustomObjectType.gai) ...[
                Row(
                  children: [
                    Text(
                      widget.initialType == CustomObjectType.kamera
                          ? 'Kamera nazorat turlari'
                          : 'Qo\'shimcha nazorat turlari',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: activeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Multi',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _features.map((f) {
                    final isSelected = _selectedFeatures.contains(f.id);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (isSelected) {
                            _selectedFeatures.remove(f.id);
                          } else {
                            _selectedFeatures.add(f.id);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? f.color.withOpacity(0.18) : inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? f.color : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              f.icon,
                              color: isSelected ? f.color : (isDark ? Colors.white70 : Colors.black54),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              f.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? (isDark ? Colors.white : f.color) : textColor,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: f.color,
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
              ],

              // 3. Optional Comment / Note
              Text(
                'Qo\'shimcha izoh (ixtiyoriy)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _noteController,
                  style: TextStyle(color: textColor, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: widget.initialType == CustomObjectType.gai
                        ? 'Masalan: O\'ng tomonda reyd o\'tkazilmoqda'
                        : widget.initialType == CustomObjectType.radar
                            ? 'Masalan: Yangi o\'rnatildi, yaxshi yashiringan'
                            : 'Masalan: Yangi o\'rnatilgan kamera',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: activeColor,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              widget.initialType == CustomObjectType.gai
                                  ? 'YPX bor deb xabar berish'
                                  : widget.initialType == CustomObjectType.radar
                                      ? 'Radarni xaritaga qo\'shish'
                                      : 'Kamerani xaritaga qo\'shish',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
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
    );
  }
}
