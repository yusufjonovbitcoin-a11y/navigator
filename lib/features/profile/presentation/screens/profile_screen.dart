import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/profile/presentation/providers/profile_provider.dart';
import 'package:navigator/features/profile/presentation/widgets/driving_telematics_card.dart';
import 'package:navigator/features/profile/presentation/widgets/leaderboard_tab.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:navigator/features/settings/presentation/screens/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final profileAsync = ref.watch(userProfileProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);
    final brandColor = isDark ? AppColors.primary : const Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          tr.tr('tab_profile'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.gear_alt_fill,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
              size: 22,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. iOS User Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A).withOpacity(0.80) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: brandColor,
                            child: Text(
                              profile.avatarInitials,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      CupertinoIcons.checkmark_seal_fill,
                                      color: Color(0xFF34C759),
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.email,
                                  style: TextStyle(fontSize: 13, color: subtextColor),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34C759).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    profile.driverLevelTitle,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF34C759)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: brandColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: brandColor.withOpacity(0.4)),
                            ),
                            child: Column(
                              children: [
                                Text(tr.tr('rank'), style: TextStyle(fontSize: 10, color: subtextColor)),
                                Text(
                                  '#${profile.rankPosition}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: brandColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Driving Telematics & Weekly AI Behavior Report
                const DrivingTelematicsCard(),
                const SizedBox(height: 16),

                // 3. 4-Metrics Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        tr.tr('distance_driven'),
                        '${profile.totalDistanceKm} km',
                        CupertinoIcons.car_detailed,
                        brandColor,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        tr.tr('speeding_events'),
                        '${profile.speedingEventsCount}',
                        CupertinoIcons.speedometer,
                        const Color(0xFF34C759),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        tr.tr('points_earned'),
                        '+${ref.watch(userKarmaProvider)} pts',
                        CupertinoIcons.star_fill,
                        const Color(0xFFFF9500),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        tr.tr('clean_trips'),
                        '${profile.cleanTripsCount}',
                        CupertinoIcons.checkmark_shield_fill,
                        const Color(0xFF34C759),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Leaderboard Section
                Row(
                  children: [
                    Icon(CupertinoIcons.rosette, color: brandColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      tr.tr('leaderboard'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Leaderboard List
                leaderboardAsync.when(
                  data: (entries) => LeaderboardTab(entries: entries),
                  loading: () => const Center(child: CupertinoActivityIndicator()),
                  error: (err, _) => Text('Error loading leaderboard: $err', style: TextStyle(color: subtextColor)),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CupertinoActivityIndicator(radius: 16),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: TextStyle(color: subtextColor)),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color iconColor, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: subtextColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
