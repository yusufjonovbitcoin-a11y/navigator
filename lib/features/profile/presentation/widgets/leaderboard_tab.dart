import 'package:flutter/cupertino.dart';
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
    final brandColor = isDark ? AppColors.primary : const Color(0xFF007AFF);
    final lang = Localizations.localeOf(context).languageCode;

    // Find account owner (current user)
    final currentUser = entries.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => entries.isNotEmpty
          ? entries.first
          : const LeaderboardEntry(
              rank: 1,
              userId: 'usr_me',
              userName: 'You',
              avatarInitials: 'ME',
              safetyScore: 94,
              karmaPoints: 340,
              distanceKm: 1420.5,
              isCurrentUser: true,
            ),
    );

    // Top 10 entries
    final top10Entries = entries.take(10).toList();

    final top10Header = lang == 'uz'
        ? 'TOP 10 PESHQADAMLAR'
        : lang == 'ru'
            ? 'ТОП 10 ЛИДЕРОВ'
            : 'TOP 10 LEADERS';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Account owner always pinned above Rank #1 showing their position
        _buildCurrentUserPinnedCard(
          context: context,
          entry: currentUser,
          isDark: isDark,
          textColor: textColor,
          subtextColor: subtextColor,
          brandColor: brandColor,
          lang: lang,
        ),

        // Section header for Top 10
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(CupertinoIcons.flame_fill, size: 14, color: Color(0xFFFF9500)),
              const SizedBox(width: 6),
              Text(
                top10Header,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: subtextColor,
                ),
              ),
              const Spacer(),
              Text(
                '1–${top10Entries.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),

        // 2. Top 10 List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: top10Entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final entry = top10Entries[idx];
            return _buildEntryRow(
              entry: entry,
              isDark: isDark,
              textColor: textColor,
              subtextColor: subtextColor,
              brandColor: brandColor,
              lang: lang,
            );
          },
        ),

        const SizedBox(height: 12),

        // 3. Bottom Button/Icon to view Top 100
        _buildTop100Button(
          context: context,
          entries: entries,
          currentUser: currentUser,
          isDark: isDark,
          textColor: textColor,
          subtextColor: subtextColor,
          brandColor: brandColor,
          lang: lang,
        ),
      ],
    );
  }

  /// Pinned card for the account owner above Rank #1
  Widget _buildCurrentUserPinnedCard({
    required BuildContext context,
    required LeaderboardEntry entry,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required Color brandColor,
    required String lang,
  }) {
    final posLabel = lang == 'uz'
        ? 'SIZNING O\'RNINGIZ'
        : lang == 'ru'
            ? 'ВАША ПОЗИЦИЯ'
            : 'YOUR POSITION';
    final youTag = lang == 'uz' ? 'SIZ' : lang == 'ru' ? 'ВЫ' : 'YOU';
    final drivenText = lang == 'uz' ? 'km yurildi' : lang == 'ru' ? 'км' : 'km';
    final rankSuffix = lang == 'uz' ? '-o\'rinda' : lang == 'ru' ? ' место' : ' place';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFF0F7FF),
                  Colors.white,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: brandColor.withOpacity(isDark ? 0.6 : 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: brandColor.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag
            Row(
              children: [
                Icon(CupertinoIcons.sparkles, size: 14, color: brandColor),
                const SizedBox(width: 6),
                Text(
                  posLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: brandColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${entry.rank}$rankSuffix',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: brandColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Rank number badge
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [brandColor, brandColor.withOpacity(0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: brandColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '#${entry.rank}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar
                CircleAvatar(
                  radius: 19,
                  backgroundColor: brandColor,
                  child: Text(
                    entry.avatarInitials,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: brandColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              youTag,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: brandColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.distanceKm.toStringAsFixed(0)} $drivenText • ${entry.karmaPoints} karma',
                        style: TextStyle(fontSize: 11.5, color: subtextColor),
                      ),
                    ],
                  ),
                ),

                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          ],
        ),
      ),
    );
  }

  /// Single entry row widget
  Widget _buildEntryRow({
    required LeaderboardEntry entry,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required Color brandColor,
    required String lang,
  }) {
    final isTop3 = entry.rank <= 3;
    final rankColor = entry.rank == 1
        ? const Color(0xFFFFD700) // Gold
        : entry.rank == 2
            ? const Color(0xFFC0C0C0) // Silver
            : entry.rank == 3
                ? const Color(0xFFCD7F32) // Bronze
                : subtextColor;

    final youTag = lang == 'uz' ? 'SIZ' : lang == 'ru' ? 'ВЫ' : 'YOU';
    final drivenText = lang == 'uz' ? 'km yurildi' : lang == 'ru' ? 'км' : 'km';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF007AFF).withOpacity(0.08))
            : (isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isCurrentUser
              ? brandColor
              : (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA)),
          width: entry.isCurrentUser ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
            blurRadius: 8,
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
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar Initials
          CircleAvatar(
            radius: 17,
            backgroundColor: entry.isCurrentUser
                ? brandColor
                : (isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE5E5EA)),
            child: Text(
              entry.avatarInitials,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: entry.isCurrentUser ? Colors.white : textColor,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: brandColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          youTag,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: brandColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${entry.distanceKm.toStringAsFixed(0)} $drivenText • ${entry.karmaPoints} karma',
                  style: TextStyle(fontSize: 11, color: subtextColor),
                ),
              ],
            ),
          ),

          // Score badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.safetyScore} pts',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF34C759),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom button to view Top 100
  Widget _buildTop100Button({
    required BuildContext context,
    required List<LeaderboardEntry> entries,
    required LeaderboardEntry currentUser,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required Color brandColor,
    required String lang,
  }) {
    final title = lang == 'uz'
        ? 'Top 100 talikni ko\'rish'
        : lang == 'ru'
            ? 'Показать топ 100'
            : 'View Top 100';
    final subtitle = lang == 'uz'
        ? 'Barcha 100 ta eng yaxshi haydovchilar'
        : lang == 'ru'
            ? 'Рейтинг 100 лучших водителей города'
            : 'All top 100 safe drivers';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openTop100Modal(
          context: context,
          entries: entries,
          currentUser: currentUser,
          isDark: isDark,
          textColor: textColor,
          subtextColor: subtextColor,
          brandColor: brandColor,
          lang: lang,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: brandColor.withOpacity(isDark ? 0.4 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: brandColor.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.list_number,
                  color: brandColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: brandColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '100',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Open Cupertino Modal Bottom Sheet showing full Top 100
  void _openTop100Modal({
    required BuildContext context,
    required List<LeaderboardEntry> entries,
    required LeaderboardEntry currentUser,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required Color brandColor,
    required String lang,
  }) {
    final modalTitle = lang == 'uz'
        ? 'Top 100 Peshqadamlar'
        : lang == 'ru'
            ? 'Таблица лидеров — Топ 100'
            : 'Top 100 Drivers';
    final userRankText = lang == 'uz'
        ? 'Sizning o\'rningiz: #${currentUser.rank} • ${currentUser.safetyScore} ball'
        : lang == 'ru'
            ? 'Ваша позиция: #${currentUser.rank} • ${currentUser.safetyScore} баллов'
            : 'Your Rank: #${currentUser.rank} • ${currentUser.safetyScore} pts';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF2F2F7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pull handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.rosette, color: brandColor, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        modalTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: subtextColor,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),

              // User Position sticky banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: brandColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.person_crop_circle_badge_checkmark, color: brandColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userRankText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      currentUser.userName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: brandColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // 100 entries list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final entry = entries[idx];
                    return _buildEntryRow(
                      entry: entry,
                      isDark: isDark,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      brandColor: brandColor,
                      lang: lang,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
