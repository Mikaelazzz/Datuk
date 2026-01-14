import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

/// Large circular diagnose button with pulse animation
class DiagnoseButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const DiagnoseButton({super.key, this.onPressed});

  @override
  State<DiagnoseButton> createState() => _DiagnoseButtonState();
}

class _DiagnoseButtonState extends State<DiagnoseButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pingController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Button with animations
        SizedBox(
          width: 256,
          height: 256,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ping animation (outer)
              AnimatedBuilder(
                animation: _pingController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pingController.value * 0.3),
                    child: Opacity(
                      opacity: 1.0 - _pingController.value,
                      child: Container(
                        width: 192,
                        height: 192,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Pulse animation (inner)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale =
                      1.0 +
                      (0.05 *
                          (1 + math.cos(_pulseController.value * 2 * 3.14159)) /
                          2);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 208,
                      height: 208,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),

              // Main button
              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  widget.onPressed?.call();
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mic,
                          color: AppColors.darkText,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Mulai\nDiagnosa',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Helper text
        Text(
          'Tekan tombol untuk mulai merekam batuk',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Helper widget for animated builder
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
