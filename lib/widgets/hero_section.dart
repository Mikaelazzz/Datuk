import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// Hero section with image, gradient overlay, and text content
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 450, // Limit maximum height to save space
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 0.85,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    AnimatedScale(
                      scale: _isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBHwvTVIchiiNVPjtom7EaObs7z3_ZveTsL3qEVDMJxRdbXsG0Sy7QQol9JYxhJX9gr-U4VvK3ZBiTMDqRINEN3-fvltypeXlpQPk9soZEBOVt9NhU-1L7IOZSaeTI5Rj6F6ls1MMeo-zyOopIkvIopaJWVlpE1CHAJRFVhVgpQWUKZWABR2fM-jplivjjlPgDYgVgO5OUfU6LISDdLlatwWCHF5V5f8a-lkOEr8e595S_nWz9oeVm5Gs5HQk0rBtBODEQ-dtvlp7yb',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.gray200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.gray200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppColors.gray400,
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Text Content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Find clarity in your thoughts.',
                              style: AppTextStyles.displayLarge.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Let Datuk listen, analyze, and guide you to a simpler understanding.',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
