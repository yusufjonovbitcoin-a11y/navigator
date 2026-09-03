import 'package:flutter/material.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/features/profile/domain/models/leaderboard_entry.dart';

class LeaderboardTab extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardTab({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final entry = entries[idx];
        final isTop3 = entry.rank <= 3;
        final rankColor = entry.rank == 1
            ? const Color(0xFFFFD700) // Gold
            : entry.rank == 2
                ? const Color(0xFFC0C0C0) // Silver
                : entry.rank == 3
                    ? const Color(0xFFCD7F32) // Bronze
                    : subtextColor;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: entry.isCurrentUser
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF007AFF).withOpacity(0.08))
                : (isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: entry.isCurrentUser
                  ? (isDark ? AppColors.primary : const Color(0xFF007AFF))
                  : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E5EA)),
              width: entry.isCurrentUser ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank number
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isTop3 ? rankColor.withOpacity(0.18) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: rankColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Avatar Initials
              CircleAvatar(
                radius: 18,
                backgroundColor: entry.isCurrentUser
                    ? (isDark ? AppColors.primary : const Color(0xFF007AFF))
                    : (isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE5E5EA)),
                child: Text(
                  entry.avatarInitials,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: entry.isCurrentUser
                        ? (isDark ? Colors.black : Colors.white)
                        : textColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.userName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (entry.isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.primary : const Color(0xFF007AFF)).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SIZ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.distanceKm.toStringAsFixed(0)} km yurildi • ${entry.karmaPoints} karma',
                      style: TextStyle(fontSize: 11.5, color: subtextColor),
                    ),
                  ],
                ),
              ),

              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.safetyScore} pts',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF34C759),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
