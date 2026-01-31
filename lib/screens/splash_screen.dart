import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import 'landing_page.dart';

/// Splash screen with loading animation and progress bar
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();

    // Start progress animation
    _startProgress();
  }

  void _startProgress() {
    const totalDuration = 3000; // 3 seconds
    const updateInterval = 20; // Update every 20ms
    const totalSteps = totalDuration / updateInterval;
    final incrementPerStep = 1.0 / totalSteps;

    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        _progress += incrementPerStep;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _navigateToLanding();
        }
      });
    });
  }

  void _navigateToLanding() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LandingPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App name
                Text(
                  'DATUK',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: 8,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Diagnosa Batuk Cerdas',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(flex: 1),

                // Lottie animation
                Lottie.asset(
                  'lib/assets/loading.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 32),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(
                    children: [
                      // Progress bar container
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.gray200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Percentage text
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    'Powered by AI',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
