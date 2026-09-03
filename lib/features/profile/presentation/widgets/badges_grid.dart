import 'package:flutter/material.dart';
import 'package:navigator/features/profile/domain/models/badge_item.dart';

class BadgesGrid extends StatelessWidget {
  final List<BadgeItem> badges;

  const BadgesGrid({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: badges.length,
      itemBuilder: (context, idx) {
        final badge = badges[idx];
        final iconColor = badge.isUnlocked ? badge.color : (isDark ? Colors.white38 : Colors.black26);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: badge.isUnlocked
                  ? badge.color.withOpacity(0.4)
                  : (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA)),
              width: badge.isUnlocked ? 1.2 : 0.8,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(badge.icon, color: iconColor, size: 20),
                  ),
                  if (badge.isUnlocked)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF34C759), size: 18)
                  else
                    Icon(Icons.lock_outline_rounded, color: subtextColor, size: 16),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                badge.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                badge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: subtextColor, height: 1.25),
              ),
            ],
          ),
        );
      },
    );
  }
}
