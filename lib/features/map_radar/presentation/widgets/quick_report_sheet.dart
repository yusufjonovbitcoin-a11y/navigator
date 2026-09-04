import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/presentation/providers/pothole_placement_provider.dart';
import 'package:navigator/features/reports/presentation/providers/report_adjustment_provider.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';

class QuickReportSheet extends ConsumerStatefulWidget {
  final double currentLat;
  final double currentLng;

  const QuickReportSheet({
    super.key,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  ConsumerState<QuickReportSheet> createState() => _QuickReportSheetState();
}

class _QuickReportSheetState extends ConsumerState<QuickReportSheet> {
  bool _isSubmitting = false;

  void _submit(ReportType type) async {
    HapticFeedback.mediumImpact();

    // Opasnaya yama: tayoqchani belgilangan joyga olib borib tepada saqlash
    if (type == ReportType.pothole) {
      Navigator.pop(context);
      ref.read(potholePlacementProvider.notifier).startPlacing();
      return;
    }

    setState(() => _isSubmitting = true);
    final tr = AppLocalizations.of(context);

    // Multiradar darhol kartada joylanadi
    final report = await ref.read(reportListProvider.notifier).createReport(
          type: type,
          lat: widget.currentLat,
          lng: widget.currentLng,
          address: 'Toshkent koordinatasi (${widget.currentLat.toStringAsFixed(4)}, ${widget.currentLng.toStringAsFixed(4)})',
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    if (report != null) {
      if (type == ReportType.stationaryRadar || type == ReportType.policePatrol) {
        // 2 martagacha ustiga bosib turib siljitish rejimi
        ref.read(reportAdjustmentProvider.notifier).start(
              reportId: report.id,
              type: type,
              initialPos: LatLng(widget.currentLat, widget.currentLng),
              maxMoves: 2,
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: const Color(0xFF0F172A),
            elevation: 6,
            content: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr.tr('report_sent'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final options = [
      (
        ReportType.stationaryRadar,
        tr.tr('stationary_camera'),
        Icons.radar_rounded,
        const Color(0xFFEF4444),
      ),
      (
        ReportType.policePatrol,
        tr.tr('mobile_patrol'),
        CupertinoIcons.shield_fill,
        const Color(0xFF2563EB),
      ),
      (
        ReportType.pothole,
        tr.tr('pothole'),
        CupertinoIcons.exclamationmark_triangle_fill,
        const Color(0xFF8B5CF6),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset > 0 ? bottomInset + 12 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // iOS Top Drag Indicator
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header: Title, Subtitle, and Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.tr('quick_report'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr.tr('select_hazard_desc'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CupertinoActivityIndicator(radius: 16),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.96,
              ),
              itemCount: options.length,
              itemBuilder: (context, idx) {
                final item = options[idx];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _submit(item.$1),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: item.$4.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(item.$3, color: item.$4, size: 24),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                              height: 1.25,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 16),

          // iPhone Style Cancel Button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  tr.tr('cancel'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
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
