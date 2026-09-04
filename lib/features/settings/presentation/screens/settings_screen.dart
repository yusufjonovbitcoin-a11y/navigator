import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final tr = AppLocalizations.of(context);
    final isDark = settings.isDarkMode;

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF8E8E93);
    final dividerColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.background : const Color(0xFFF2F2F7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDark ? Colors.white : Colors.black,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr.tr('settings_title'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Language Section
          _buildSectionHeader(tr.tr('language'), isDark),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: AppLanguage.values.asMap().entries.map((entry) {
                final idx = entry.key;
                final lang = entry.value;
                final isSelected = settings.language == lang;
                final isLast = idx == AppLanguage.values.length - 1;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Text(
                        '${lang.flag}  ${lang.label}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                      ),
                      trailing: isSelected
                          ? Icon(CupertinoIcons.checkmark_alt, color: isDark ? AppColors.primary : const Color(0xFF007AFF), size: 22)
                          : null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.setLanguage(lang);
                      },
                    ),
                    if (!isLast) Divider(height: 1, indent: 16, color: dividerColor),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Alert & Sound Preferences
          _buildSectionHeader(
            settings.language.code == 'ru'
                ? 'ГОЛОСОВЫЕ ОПОВЕЩЕНИЯ И ЗВУКИ'
                : settings.language.code == 'uz'
                    ? 'OVOZ VA OGOHLANTIRISHLAR'
                    : 'VOICE & RADAR ALERTS',
            isDark,
          ),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary.withOpacity(0.18) : const Color(0xFF007AFF).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                CupertinoIcons.speaker_2_fill,
                                color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tr.tr('voice_alerts'),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: settings.voiceAlertsEnabled,
                        activeTrackColor: isDark ? AppColors.primary : const Color(0xFF007AFF),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          notifier.setVoiceAlerts(val);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 16, color: dividerColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary.withOpacity(0.18) : const Color(0xFF007AFF).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                CupertinoIcons.bell_fill,
                                color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tr.tr('sound_chimes'),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: settings.soundChimesEnabled,
                        activeTrackColor: isDark ? AppColors.primary : const Color(0xFF007AFF),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          notifier.setSoundChimes(val);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 16, color: dividerColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.radarRed.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(CupertinoIcons.gauge, color: AppColors.radarRed, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tr.tr('alert_distance'),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: settings.alertDistanceMeters,
                            isDense: true,
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            icon: Icon(CupertinoIcons.chevron_down, color: subtextColor, size: 13),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : textColor,
                            ),
                            items: const [
                              DropdownMenuItem(value: 300, child: Text('300 m')),
                              DropdownMenuItem(value: 500, child: Text('500 m')),
                              DropdownMenuItem(value: 1000, child: Text('1000 m')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                HapticFeedback.selectionClick();
                                notifier.setAlertDistance(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Units & Theme Appearance Section
          _buildSectionHeader(
            settings.language.code == 'ru'
                ? 'ВНЕШНИЙ ВИД И ЕДИНИЦЫ ИЗМЕРЕНИЯ'
                : settings.language.code == 'uz'
                    ? 'TASHQI KO\'RINISH VA O\'LCHOV BIRLIKLARI'
                    : 'APPEARANCE & UNITS',
            isDark,
          ),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                // Theme Mode Appearance Switcher (Dark 🌙 / White ☀️)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFFF9500).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isDark ? CupertinoIcons.moon_stars_fill : CupertinoIcons.sun_max_fill,
                                color: isDark ? AppColors.primary : const Color(0xFFFF9500),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                settings.language.code == 'ru'
                                    ? 'Тема'
                                    : settings.language.code == 'uz'
                                        ? 'Mavzu'
                                        : 'Theme',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSlidingSegmentedControl<bool>(
                        groupValue: settings.isDarkMode,
                        thumbColor: isDark ? AppColors.primary : Colors.white,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA),
                        children: {
                          false: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.sun_max_fill, size: 13, color: Color(0xFFFF9500)),
                                const SizedBox(width: 4),
                                Text(
                                  settings.language.code == 'ru' ? 'Светлая' : settings.language.code == 'uz' ? 'Yorug\'' : 'Light',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !isDark ? Colors.black : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          true: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.moon_fill, size: 13, color: isDark ? Colors.black : Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  settings.language.code == 'ru' ? 'Темная' : settings.language.code == 'uz' ? 'Qorong\'i' : 'Dark',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.black : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        },
                        onValueChanged: (val) {
                          if (val != null) {
                            HapticFeedback.selectionClick();
                            notifier.setDarkMode(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 16, color: dividerColor),

                // Speed Units Switcher
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary.withOpacity(0.18) : const Color(0xFF007AFF).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                CupertinoIcons.speedometer,
                                color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  tr.tr('units'),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSlidingSegmentedControl<String>(
                        groupValue: settings.units,
                        thumbColor: isDark ? AppColors.primary : Colors.white,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA),
                        children: {
                          'km/h': Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text(
                              'km/h',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: settings.units == 'km/h' ? (isDark ? Colors.black : const Color(0xFF007AFF)) : textColor,
                              ),
                            ),
                          ),
                          'mph': Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text(
                              'mph',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: settings.units == 'mph' ? (isDark ? Colors.black : const Color(0xFF007AFF)) : textColor,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (val) {
                          if (val != null) {
                            HapticFeedback.selectionClick();
                            notifier.setUnits(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // iOS App Version Footnote
          Center(
            child: Text(
              'Radar AI Navigator • iOS 18 Edition\nv1.0.0 (Build 2026.1)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: subtextColor, height: 1.4),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark ? Colors.white.withOpacity(0.45) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: isDark ? const Color(0xFF0F172A).withOpacity(0.80) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          elevation: isDark ? 0 : 2,
          shadowColor: Colors.black.withOpacity(0.04),
          child: child,
        ),
      ),
    );
  }
}
