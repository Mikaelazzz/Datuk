import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// Individual step card widget with icon, title, description, and badge
class StepCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String stepNumber;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;

  const StepCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.stepNumber,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
  });

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.gray100,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.headingMedium.copyWith(
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.badgeBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.stepNumber,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.badgeTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
