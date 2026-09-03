import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/map_radar/presentation/providers/parking_zone_provider.dart';

class SaveParkingDialog extends ConsumerStatefulWidget {
  const SaveParkingDialog({super.key});

  @override
  ConsumerState<SaveParkingDialog> createState() => _SaveParkingDialogState();
}

class _SaveParkingDialogState extends ConsumerState<SaveParkingDialog> {
  final TextEditingController _nameController = TextEditingController(text: 'Mening Parkovkam');
  final TextEditingController _priceController = TextEditingController(text: '5,000 so\'m/soat');
  final TextEditingController _capacityController = TextEditingController(text: '30');
  bool _isPaid = true;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _save() {
    HapticFeedback.mediumImpact();
    final name = _nameController.text.trim();
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 20;
    final price = _isPaid ? _priceController.text.trim() : 'Bepul';

    final success = ref.read(parkingZoneProvider.notifier).saveCurrentZone(
          name: name.isEmpty ? 'Yangi Parkovka' : name,
          isPaid: _isPaid,
          priceInfo: price.isEmpty ? '5,000 so\'m/soat' : price,
          capacity: capacity,
        );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Parkovka zonasi muvaffaqiyatli saqlandi!'),
            ],
          ),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputBg = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7);
    final borderColor = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(CupertinoIcons.placemark_fill, color: Color(0xFF007AFF), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parkovka Zonasini Saqlash',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Chizilgan ko\'pburchak maydonni nomlang',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name Field
            Text(
              'Parkovka Nomi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _nameController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Masalan: Chilonzor Mall Parkovkasi',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Paid / Free Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To\'lov turi',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    Text(
                      _isPaid ? 'Pullik avtoturargoh' : 'Bepul avtoturargoh',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                CupertinoSlidingSegmentedControl<bool>(
                  groupValue: _isPaid,
                  children: {
                    false: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text('Bepul', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
                    ),
                    true: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text('Pullik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
                    ),
                  },
                  onValueChanged: (val) {
                    if (val != null) setState(() => _isPaid = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Field (if paid) & Capacity
            Row(
              children: [
                if (_isPaid)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Narxi',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: TextField(
                            controller: _priceController,
                            style: TextStyle(color: textColor, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: '5,000 so\'m/soat',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isPaid) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sig\'imi (joy)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller: _capacityController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textColor, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: '30',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Bekor qilish',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF1C1C1E),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: _save,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Saqlash',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
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
}
