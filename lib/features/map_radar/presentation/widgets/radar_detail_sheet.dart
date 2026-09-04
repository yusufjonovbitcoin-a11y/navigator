import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/constants/app_typography.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';

class RadarDetailSheet extends StatelessWidget {
  final RadarPoint radar;
  final VoidCallback onConfirm;

  const RadarDetailSheet({
    super.key,
    required this.radar,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.jm().format(radar.lastConfirmed);

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
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.radarRed.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.radarRed, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(radar.title, style: AppTypography.heading2),
                    const SizedBox(height: 2),
                    Text(
                      radar.address ?? 'Tashkent Metro Area',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.radarRed, width: 3),
                ),
                child: Text(
                  '${radar.speedLimit}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Confirmations', '${radar.confirmedCount} drivers', Icons.thumb_up_alt_rounded),
                Container(width: 1, height: 32, color: AppColors.border),
                _buildStatItem('Last Verified', timeStr, Icons.access_time_rounded),
                Container(width: 1, height: 32, color: AppColors.border),
                _buildStatItem('Status', 'Active', Icons.check_circle_rounded),
              ],
            ),
          ),
          if (radar.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Qo\'shimcha nazorat qilinadi:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: radar.features.map((f) {
                String label;
                IconData icon;
                Color color;
                switch (f) {
                  case 'kamar':
                    label = 'Xavfsizlik kamari';
                    icon = Icons.airline_seat_recline_normal_rounded;
                    color = const Color(0xFF10B981);
                    break;
                  case 'telefon':
                    label = 'Rulda telefon';
                    icon = Icons.phone_iphone_rounded;
                    color = const Color(0xFF6366F1);
                    break;
                  case 'palasa':
                    label = 'Yo\'l chizig\'i (Palasa)';
                    icon = Icons.alt_route_rounded;
                    color = const Color(0xFFF59E0B);
                    break;
                  case 'svetofor':
                    label = 'Svetofor (Qizil)';
                    icon = Icons.traffic_rounded;
                    color = const Color(0xFFEF4444);
                    break;
                  default:
                    label = f;
                    icon = Icons.check_circle_outline;
                    color = AppColors.primary;
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Radar confirmed! Thank you for helping drivers.')),
                );
              },
              icon: const Icon(Icons.thumb_up_alt_rounded, color: Colors.black, size: 18),
              label: const Text('Confirm Still Here (+5 Karma pts)'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }
}
