import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/constants/app_typography.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:navigator/main_screen_wrapper.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _locationGranted = true;
  bool _micGranted = true;
  bool _notifGranted = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreenWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final settings = ref.watch(settingsNotifierProvider);

    final pages = [
      _OnboardingSlide(
        icon: Icons.radar_rounded,
        iconColor: AppColors.radarRed,
        title: tr.tr('onboarding_title_1'),
        desc: tr.tr('onboarding_desc_1'),
      ),
      _OnboardingSlide(
        icon: Icons.psychology_rounded,
        iconColor: AppColors.primary,
        title: tr.tr('onboarding_title_2'),
        desc: tr.tr('onboarding_desc_2'),
      ),
      _OnboardingSlide(
        icon: Icons.groups_rounded,
        iconColor: AppColors.safeGreen,
        title: tr.tr('onboarding_title_3'),
        desc: tr.tr('onboarding_desc_3'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar: Language Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        tr.tr('choose_language'),
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AppLanguage>(
                        value: settings.language,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                        items: AppLanguage.values.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(
                              '${lang.flag} ${lang.label}',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (lang) {
                          if (lang != null) {
                            ref.read(settingsNotifierProvider.notifier).setLanguage(lang);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Page Slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length + 1,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, index) {
                    if (index < pages.length) {
                      return pages[index];
                    } else {
                      return _buildPermissionsPage(tr);
                    }
                  },
                ),
              ),

              // Page Indicators & Bottom Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length + 1, (index) {
                  return AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Next / Start Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < pages.length) {
                      _pageController.nextPage(
                        duration: 350.ms,
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == pages.length
                            ? tr.tr('get_started')
                            : tr.tr('start'),
                        style: AppTypography.button.copyWith(color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsPage(AppLocalizations tr) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGlow,
                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
              ),
              child: const Icon(
                Icons.security_rounded,
                size: 46,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              tr.tr('permissions_title'),
              style: AppTypography.heading1,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              tr.tr('permissions_desc'),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ),
          const SizedBox(height: 32),

          // Permission Items
          _PermissionToggleCard(
            title: 'Location Services',
            desc: tr.tr('perm_location'),
            icon: Icons.location_on_rounded,
            iconColor: AppColors.safeGreen,
            value: _locationGranted,
            onChanged: (val) {
              setState(() => _locationGranted = val);
              ref.read(locationServiceProvider).checkAndRequestPermissions();
            },
          ),
          const SizedBox(height: 14),
          _PermissionToggleCard(
            title: 'Microphone & Voice',
            desc: tr.tr('perm_mic'),
            icon: Icons.mic_rounded,
            iconColor: AppColors.primary,
            value: _micGranted,
            onChanged: (val) => setState(() => _micGranted = val),
          ),
          const SizedBox(height: 14),
          _PermissionToggleCard(
            title: 'Notifications',
            desc: tr.tr('perm_notifications'),
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.cautionAmber,
            value: _notifGranted,
            onChanged: (val) => setState(() => _notifGranted = val),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;

  const _OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.12),
            border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, size: 64, color: iconColor),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 40),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.heading1,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 350.ms),
        ),
      ],
    );
  }
}

class _PermissionToggleCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionToggleCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.heading3.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
