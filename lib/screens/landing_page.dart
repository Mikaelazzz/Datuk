import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/step_card.dart';
import '../widgets/floating_cta_button.dart';

/// Main landing page for the Datuk app
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero Section
                const HeroSection(),

                // "How it works" Divider
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : AppColors.gray200,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'HOW IT WORKS',
                          style: AppTextStyles.labelBold.copyWith(
                            color: isDark
                                ? AppColors.primary.withOpacity(0.8)
                                : AppColors.secondaryText,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : AppColors.gray200,
                        ),
                      ),
                    ],
                  ),
                ),

                // Steps Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Step 1: Record
                      StepCard(
                        icon: Icons.mic,
                        title: 'Record',
                        description:
                            'Just speak naturally. We\'re listening without judgment.',
                        stepNumber: 'Step 1',
                        iconBackgroundColor: AppColors.primary.withOpacity(0.2),
                        iconColor: isDark
                            ? AppColors.primary
                            : AppColors.primaryDark,
                        badgeBackgroundColor: AppColors.primary.withOpacity(
                          0.1,
                        ),
                        badgeTextColor: AppColors.secondaryText,
                      ),
                      const SizedBox(height: 6),

                      // Step 2: Analyze
                      StepCard(
                        icon: Icons.psychology,
                        title: 'Analyze',
                        description:
                            'Datuk processes your thoughts instantly to find patterns.',
                        stepNumber: 'Step 2',
                        iconBackgroundColor: isDark
                            ? AppColors.blue900.withOpacity(0.3)
                            : AppColors.blue100,
                        iconColor: isDark
                            ? AppColors.blue400
                            : AppColors.blue600,
                        badgeBackgroundColor: isDark
                            ? AppColors.blue900.withOpacity(0.3)
                            : AppColors.blue50,
                        badgeTextColor: isDark
                            ? AppColors.blue300
                            : AppColors.blue600,
                      ),
                      const SizedBox(height: 6),

                      // Step 3: Result
                      StepCard(
                        icon: Icons.lightbulb,
                        title: 'Result',
                        description:
                            'Get clear, actionable insights to improve your day.',
                        stepNumber: 'Step 3',
                        iconBackgroundColor: isDark
                            ? AppColors.purple900.withOpacity(0.3)
                            : AppColors.purple100,
                        iconColor: isDark
                            ? AppColors.purple400
                            : AppColors.purple600,
                        badgeBackgroundColor: isDark
                            ? AppColors.purple900.withOpacity(0.3)
                            : AppColors.purple50,
                        badgeTextColor: isDark
                            ? AppColors.purple300
                            : AppColors.purple600,
                      ),
                    ],
                  ),
                ),

                // Bottom spacer for floating button
                const SizedBox(height: 70),
              ],
            ),
          ),

          // Floating CTA Button
          FloatingCtaButton(
            onPressed: () {
              // Handle CTA button press
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Starting your session...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
