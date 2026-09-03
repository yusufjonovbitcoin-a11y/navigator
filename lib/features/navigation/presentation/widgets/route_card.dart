import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';

class RouteCard extends StatelessWidget {
  final RouteInfo route;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = route.isSafest
        ? const Color(0xFF34C759)
        : (isDark ? const Color(0xFF00E5FF) : const Color(0xFF007AFF));

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.65) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4))
              : (isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? themeColor
                : (isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA)),
            width: isSelected ? 2.0 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? themeColor.withOpacity(0.25) : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: themeColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        route.isSafest ? CupertinoIcons.shield_fill : CupertinoIcons.bolt_fill,
                        size: 13,
                        color: themeColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        route.isSafest ? 'Safest Route' : 'Fastest Route',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${route.durationMinutes} min',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? themeColor : textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              route.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              route.summary,
              style: TextStyle(
                fontSize: 12,
                color: subtextColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildChip(CupertinoIcons.map_pin_ellipse, '${route.distanceKm} km', isDark: isDark),
                _buildChip(
                  CupertinoIcons.camera_fill,
                  '${route.radarCount} radars',
                  color: route.radarCount <= 1 ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                  isDark: isDark,
                ),
                _buildChip(
                  CupertinoIcons.checkmark_shield_fill,
                  'Risk ${route.riskScore}/100',
                  color: route.riskScore < 30 ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, {Color? color, required bool isDark}) {
    final chipColor = color ?? (isDark ? Colors.white70 : const Color(0xFF1C1C1E));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: chipColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
