import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/map_radar/presentation/widgets/quick_report_sheet.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';
import 'package:navigator/features/reports/presentation/widgets/driving_analytics_report_view.dart';
import 'package:navigator/features/reports/presentation/widgets/my_contribution_report_view.dart';
import 'package:navigator/features/reports/presentation/widgets/report_item_card.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedSegment = 0; // 0 = Haydash Tahlili, 1 = Jonli Xabarlar, 2 = Mening Hissam
  ReportType? _selectedFilter;

  void _openQuickReportSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QuickReportSheet(
        currentLat: 39.654760,
        currentLng: 66.975830,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final reportsAsync = ref.watch(reportListProvider);
    final karma = ref.watch(userKarmaProvider);

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);
    final brandColor = isDark ? AppColors.primary : const Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _selectedSegment == 0
              ? 'Tahlil va Hisobot'
              : (_selectedSegment == 1 ? 'Yo\'l Xabarlari' : 'Mening Hissam'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: textColor,
          ),
        ),
        actions: [
          // Karma points pill
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.star_fill, size: 12, color: Color(0xFFFF9500)),
                const SizedBox(width: 4),
                Text(
                  '$karma Karma',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFF9500)),
                ),
              ],
            ),
          ),
          // Add Report Action Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: brandColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.plus, color: Colors.black, size: 18),
            ),
            onPressed: _openQuickReportSheet,
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 3-Segment Professional Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                backgroundColor: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA),
                thumbColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.chart_bar_square_fill,
                          size: 14,
                          color: _selectedSegment == 0 ? brandColor : subtextColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Tahlil',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: _selectedSegment == 0 ? FontWeight.w800 : FontWeight.w500,
                            color: _selectedSegment == 0 ? brandColor : subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.antenna_radiowaves_left_right,
                          size: 14,
                          color: _selectedSegment == 1 ? brandColor : subtextColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Xabarlar',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: _selectedSegment == 1 ? FontWeight.w800 : FontWeight.w500,
                            color: _selectedSegment == 1 ? brandColor : subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  2: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.shield_fill,
                          size: 14,
                          color: _selectedSegment == 2 ? const Color(0xFFFF9500) : subtextColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Hissam',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: _selectedSegment == 2 ? FontWeight.w800 : FontWeight.w500,
                            color: _selectedSegment == 2 ? const Color(0xFFFF9500) : subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSegment = val);
                  }
                },
              ),
            ),
          ),

          // Body View Switching
          Expanded(
            child: _selectedSegment == 0
                ? DrivingAnalyticsReportView(isDark: isDark)
                : (_selectedSegment == 2
                    ? MyContributionReportView(
                        isDark: isDark,
                        onAddReport: _openQuickReportSheet,
                      )
                    : _buildLiveCommunityReportsTab(
                        reportsAsync: reportsAsync,
                        isDark: isDark,
                        brandColor: brandColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        tr: tr,
                      )),
          ),
        ],
      ),
      floatingActionButton: _selectedSegment == 1
          ? Padding(
              padding: const EdgeInsets.only(bottom: 75),
              child: FloatingActionButton.extended(
                backgroundColor: brandColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 4,
                icon: const Icon(CupertinoIcons.plus_circle_fill, size: 20),
                label: const Text(
                  'Xavf / Radar qo\'shish',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                onPressed: _openQuickReportSheet,
              ),
            )
          : null,
    );
  }

  Widget _buildLiveCommunityReportsTab({
    required AsyncValue<List<UserReport>> reportsAsync,
    required bool isDark,
    required Color brandColor,
    required Color textColor,
    required Color subtextColor,
    required AppLocalizations tr,
  }) {
    return Column(
      children: [
        // Quick Live Incidents Summary Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLiveStatPill('🚔 4 YPX', const Color(0xFF007AFF)),
              _buildLiveStatPill('📷 8 Radar', const Color(0xFFFF3B30)),
              _buildLiveStatPill('⚠️ 3 Nosoz', const Color(0xFFFF9500)),
              _buildLiveStatPill('🚗 1 Avariya', const Color(0xFFA855F7)),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Quick Filter Chips (All, Radar, Police, Accident, Pothole)
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('Barchasi', null, brandColor, isDark),
              const SizedBox(width: 8),
              _buildFilterChip('Radarlar', ReportType.stationaryRadar, AppColors.radarRed, isDark),
              const SizedBox(width: 8),
              _buildFilterChip('YPX Patrul', ReportType.policePatrol, AppColors.policeBlue, isDark),
              const SizedBox(width: 8),
              _buildFilterChip('Avariyalar', ReportType.accident, const Color(0xFFEF4444), isDark),
              const SizedBox(width: 8),
              _buildFilterChip('Chuqurlar', ReportType.pothole, const Color(0xFFA855F7), isDark),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Reports List
        Expanded(
          child: reportsAsync.when(
            data: (reports) {
              var displayReports = reports;

              if (_selectedFilter != null) {
                displayReports = displayReports.where((r) => r.type == _selectedFilter).toList();
              }

              if (displayReports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_seal,
                        size: 48,
                        color: subtextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr.tr('no_reports_yet'),
                        style: TextStyle(fontSize: 14, color: subtextColor),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        onPressed: _openQuickReportSheet,
                        child: const Text('+ Xabar qo\'shish', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                itemCount: displayReports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final report = displayReports[idx];
                  return ReportItemCard(
                    report: report,
                    onUpvote: () {
                      HapticFeedback.lightImpact();
                      ref.read(reportListProvider.notifier).upvote(report.id);
                    },
                    onDownvote: () {
                      HapticFeedback.lightImpact();
                      ref.read(reportListProvider.notifier).downvote(report.id);
                    },
                  );
                },
              );
            },
            loading: () => Center(
              child: CupertinoActivityIndicator(color: brandColor, radius: 14),
            ),
            error: (err, _) => Center(
              child: Text('Error: $err', style: TextStyle(color: subtextColor)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStatPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildFilterChip(String title, ReportType? type, Color color, bool isDark) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = isSelected && type != null ? null : type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E5EA)),
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type != null) ...[
              Icon(type.icon, size: 12, color: isSelected ? color : (isDark ? Colors.white60 : Colors.black54)),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? color : (isDark ? Colors.white70 : const Color(0xFF1C1C1E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
