import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/constants/app_typography.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:navigator/main_screen_wrapper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final storage = ref.read(storageServiceProvider);
    final onboardingDone = storage.isOnboardingCompleted();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => onboardingDone
            ? const MainScreenWrapper()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Radar Scanner Animation Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGlow,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1200.ms),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    size: 48,
                    color: Colors.black,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              tr.tr('app_name'),
              style: AppTypography.heading1.copyWith(
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'AI Powered Navigation & Speed Camera Warnings',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
