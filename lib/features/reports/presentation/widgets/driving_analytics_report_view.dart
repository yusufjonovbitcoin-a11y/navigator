import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/services/driving_behavior_service.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_radar_provider.dart';
import 'package:navigator/features/profile/presentation/providers/profile_provider.dart';
import 'package:navigator/features/reports/presentation/widgets/potential_violations_sheet.dart';

class DrivingAnalyticsReportView extends ConsumerStatefulWidget {
  final bool isDark;

  const DrivingAnalyticsReportView({
    super.key,
    required this.isDark,
  });

  @override
  ConsumerState<DrivingAnalyticsReportView> createState() => _DrivingAnalyticsReportViewState();
}

class _DrivingAnalyticsReportViewState extends ConsumerState<DrivingAnalyticsReportView> {
  int _selectedPeriod = 1; // 0: Bugun, 1: Bu hafta, 2: Bu oy
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
  }

  @override
  Widget build(BuildContext context) {
    final driving = ref.watch(drivingBehaviorProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final radars = ref.watch(radarListProvider).valueOrNull ?? [];

    final todayWeekday = DateTime.now().weekday; // 1 = Monday .. 7 = Sunday
    final dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final weekDays = List.generate(7, (idx) {
      final isToday = (idx + 1) == todayWeekday;
      return {
        'day': dayNames[idx],
        'km': isToday ? driving.weeklyDistanceKm : 0.0,
        'score': isToday ? driving.safetyScore.toInt() : 100,
        'fines': isToday ? driving.violationCount : 0,
      };
    });

    final selectedDay = weekDays[_selectedDayIndex.clamp(0, 6)];

    final textColor = widget.isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = widget.isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);
    final cardBg = widget.isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white;
    final cardBorder = widget.isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        // 1. Period Selector (Bugun, Bu hafta, Bu oy)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _buildPeriodTab(0, 'Bugun'),
              _buildPeriodTab(1, 'Bu hafta'),
              _buildPeriodTab(2, 'Bu oy'),
            ],
          ),
        ),

        // 2. Main Executive Safety & Fine Savings Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF007AFF), const Color(0xFF0051C6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? const Color(0xFF00E5FF) : const Color(0xFF007AFF)).withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: widget.isDark ? const Color(0xFF00E5FF).withOpacity(0.3) : Colors.white.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Circular Score Ring (96 / 100)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: CircularProgressIndicator(
                          value: (driving.safetyScore / 100.0).clamp(0.0, 1.0),
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            driving.safetyScore >= 85 ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${driving.safetyScore.toInt()}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),

                  // Headline & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34C759).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF34C759), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF34C759), size: 12),
                              SizedBox(width: 4),
                              Text(
                                'A\'lo Haydovchi',
                                style: TextStyle(
                                  color: Color(0xFF34C759),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Xavfsiz Haydash Reytingi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'O\'zbekiston bo\'yicha eng intizomli 5% haydovchilar safida',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.75),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Bo'ysunilmagan holatlar va ehtimoliy jarimalar kartasi (Batafsil ma'lumot)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    PotentialViolationsSheet.show(
                      context,
                      periodIndex: _selectedPeriod,
                      isDark: widget.isDark,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF3B30).withOpacity(0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (driving.violationCount == 0 ? const Color(0xFF34C759) : const Color(0xFFFF3B30)).withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            driving.violationCount == 0
                                ? CupertinoIcons.checkmark_shield_fill
                                : CupertinoIcons.exclamationmark_triangle_fill,
                            color: driving.violationCount == 0 ? const Color(0xFF34C759) : const Color(0xFFFF453A),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driving.violationCount == 0
                                    ? 'Qoidabuzarliklar qayd etilmadi'
                                    : '${driving.violationCount} ta xavfli holat qayd etildi',
                                style: TextStyle(
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w800,
                                  color: driving.violationCount == 0 ? const Color(0xFF34C759) : const Color(0xFFFFD60A),
                                  height: 1.22,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                driving.violationCount == 0
                                    ? 'Barcha tezlik va yo\'l me\'yorlariga to\'liq rioya qilinmoqda'
                                    : 'Tezlik va manyovrlar telematikada tahlil qilinmoqda',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.chevron_right,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. Weekly Activity & Distance Chart
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
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
                          'Haftalik Masofa Dinamikasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Jami: ${driving.weeklyDistanceKm.toStringAsFixed(1)} km (Haftalik masofa)',
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${selectedDay['day']}: ${selectedDay['km']} km',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF34C759),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bar Chart Row
              SizedBox(
                height: 132,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(weekDays.length, (idx) {
                    final item = weekDays[idx];
                    final isSelected = idx == _selectedDayIndex;
                    final km = item['km'] as double;
                    final heightFraction = (km / 80.0).clamp(0.15, 1.0);

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDayIndex = idx);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.isDark ? AppColors.primary : const Color(0xFF007AFF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${km.toInt()}k',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          Container(
                            width: 32,
                            height: 75 * heightFraction,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                        const Color(0xFF00E5FF),
                                        const Color(0xFF007AFF),
                                      ]
                                    : [
                                        widget.isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFCBD5E1),
                                        widget.isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF007AFF).withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['day'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected
                                  ? (widget.isDark ? AppColors.primary : const Color(0xFF007AFF))
                                  : subtextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 4. Metric Cards 2x2 Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildMetricCard(
              icon: CupertinoIcons.gauge,
              iconColor: const Color(0xFF007AFF),
              title: 'O\'rtacha Tezlik',
              value: '${driving.weeklyDistanceKm > 0 ? (driving.weeklyDistanceKm / 4.0).clamp(20.0, 70.0).toInt() : 0} km/h',
              badge: 'Telematika',
              cardBg: cardBg,
              cardBorder: cardBorder,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            _buildMetricCard(
              icon: CupertinoIcons.camera_fill,
              iconColor: const Color(0xFFFF3B30),
              title: 'Radarlar',
              value: '${radars.length} ta',
              badge: 'Supabase',
              cardBg: cardBg,
              cardBorder: cardBorder,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            _buildMetricCard(
              icon: CupertinoIcons.drop_fill,
              iconColor: const Color(0xFF34C759),
              title: 'Tejalgan Yoqilg\'i',
              value: '+${driving.fuelSavedPercentage.toInt()}%',
              badge: 'Eko hisob',
              cardBg: cardBg,
              cardBorder: cardBorder,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            _buildMetricCard(
              icon: CupertinoIcons.flame_fill,
              iconColor: const Color(0xFFFF9500),
              title: 'Jarimasiz Harakat',
              value: '${profile?.cleanTripsCount ?? 0} kun',
              badge: 'Intizom',
              cardBg: cardBg,
              cardBorder: cardBorder,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 5. Driver Habits & Safety Sub-Scores
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haydash Odatlari Tahlili',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Avtomobil telematikasi va GPS tahlili asosida',
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
              const SizedBox(height: 16),
              _buildHabitRow(
                'Tezlik chegarasiga rioya qilish',
                (driving.safetyScore / 100.0).clamp(0.0, 1.0),
                '${driving.safetyScore.toInt()}%',
                const Color(0xFF34C759),
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 14),
              _buildHabitRow(
                'Silliq tormozlanish',
                (1.0 - (driving.harshBrakingCount * 0.05)).clamp(0.5, 1.0),
                '${((1.0 - (driving.harshBrakingCount * 0.05)).clamp(0.5, 1.0) * 100).toInt()}%',
                const Color(0xFF007AFF),
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 14),
              _buildHabitRow(
                'Silliq tezlanish',
                (1.0 - (driving.rapidAccelerationCount * 0.05)).clamp(0.5, 1.0),
                '${((1.0 - (driving.rapidAccelerationCount * 0.05)).clamp(0.5, 1.0) * 100).toInt()}%',
                const Color(0xFF34C759),
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 14),
              _buildHabitRow(
                'Ehtiyotkor burilish',
                (1.0 - (driving.sharpCorneringCount * 0.05)).clamp(0.5, 1.0),
                '${((1.0 - (driving.sharpCorneringCount * 0.05)).clamp(0.5, 1.0) * 100).toInt()}%',
                const Color(0xFFFF9500),
                textColor,
                subtextColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPeriodTab(int index, String title) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedPeriod = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.isDark ? const Color(0xFF1E293B) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? (widget.isDark ? AppColors.primary : const Color(0xFF007AFF))
                    : (widget.isDark ? Colors.white60 : const Color(0xFF64748B)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String badge,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: iconColor),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(fontSize: 11, color: subtextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitRow(String title, double progress, String percent, Color color, Color textColor, Color subtextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor)),
            Text(percent, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: widget.isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
