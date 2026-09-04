import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';

class ReportItemCard extends StatelessWidget {
  final UserReport report;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const ReportItemCard({
    super.key,
    required this.report,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = report.type.color;
    final timeFormatted = DateFormat.jm().format(report.timestamp);

    final remainingMins = report.expiresAt.difference(DateTime.now()).inMinutes;
    final isLevel5 = report.authorTrustLevel >= 5;

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLevel5
              ? const Color(0xFF34C759).withOpacity(0.4)
              : (isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA)),
          width: isLevel5 ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(report.type.icon, color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.type.getLocalizedTitle(tr),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: timeFormatted,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: subtextColor,
                              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                            ),
                          ),
                          if (remainingMins > 0) ...[
                            TextSpan(
                              text: ' • ',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: subtextColor,
                                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                              ),
                            ),
                            TextSpan(
                              text: remainingMins > 60
                                  ? '${(remainingMins / 60).toStringAsFixed(1)} soat qoldi'
                                  : '$remainingMins daq qoldi',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFFFF9500),
                                fontWeight: FontWeight.w700,
                                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Level 5 Instant Trust or Verified Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isLevel5
                      ? const Color(0xFF34C759).withOpacity(0.18)
                      : (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLevel5
                        ? const Color(0xFF34C759)
                        : (isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE5E5EA)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLevel5 ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.clock_fill,
                      size: 11.5,
                      color: isLevel5 ? const Color(0xFF34C759) : subtextColor,
                    ),
                    const SizedBox(width: 3.5),
                    Text(
                      isLevel5 ? 'LEVEL 5 VERIFIED' : '${report.upvotes} VOTES',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isLevel5 ? const Color(0xFF34C759) : subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (report.address != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(CupertinoIcons.location_solid, size: 14, color: isDark ? AppColors.primary : const Color(0xFF007AFF)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report.address!,
                    style: TextStyle(fontSize: 13, color: subtextColor),
                  ),
                ),
              ],
            ),
          ],
          if (report.note != null && report.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                report.note!,
                style: TextStyle(fontSize: 13, color: textColor, height: 1.3),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E5EA)),
          const SizedBox(height: 10),

          // Action Buttons: Upvote / Downvote
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Tasdiqlar: ${report.upvotes} • Yo\'q: ${report.downvotes}',
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Downvote Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onDownvote();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.hand_thumbsdown_fill, size: 13, color: Color(0xFFFF3B30)),
                          SizedBox(width: 4),
                          Text(
                            'Yo\'q',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFFFF3B30), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Upvote Button (+5 Karma)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onUpvote();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF34C759).withOpacity(0.6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.hand_thumbsup_fill, size: 13, color: Color(0xFF34C759)),
                          SizedBox(width: 5),
                          Text(
                            'Tasdiqlash (+5)',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF34C759), fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
