import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/constants/app_typography.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
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
    setState(() => _isSubmitting = true);
    final tr = AppLocalizations.of(context);

    final success = await ref.read(reportListProvider.notifier).submitReport(
          type: type,
          lat: widget.currentLat,
          lng: widget.currentLng,
          address: 'Reported at coordinates (${widget.currentLat.toStringAsFixed(4)}, ${widget.currentLng.toStringAsFixed(4)})',
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.safeGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr.tr('report_sent'),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    final options = [
      (ReportType.stationaryRadar, tr.tr('stationary_camera'), Icons.camera_alt_rounded, AppColors.radarRed),
      (ReportType.policePatrol, tr.tr('mobile_patrol'), Icons.local_police_rounded, AppColors.policeBlue),
      (ReportType.accident, tr.tr('accident'), Icons.car_crash_rounded, AppColors.hazardOrange),
      (ReportType.trafficJam, tr.tr('traffic_jam'), Icons.traffic_rounded, AppColors.cautionAmber),
      (ReportType.roadwork, tr.tr('roadwork'), Icons.construction_rounded, const Color(0xFFEAB308)),
      (ReportType.pothole, tr.tr('pothole'), Icons.warning_amber_rounded, AppColors.speedTrapPurple),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(tr.tr('quick_report'), style: AppTypography.heading2),
          const SizedBox(height: 4),
          Text(
            tr.tr('select_hazard_desc'),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 20),

          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.primary),
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
                childAspectRatio: 0.95,
              ),
              itemCount: options.length,
              itemBuilder: (context, idx) {
                final item = options[idx];
                return InkWell(
                  onTap: () => _submit(item.$1),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.$4.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.$3, color: item.$4, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
