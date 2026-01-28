import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// Recording screen for capturing cough audio
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    // TODO: Process recording and navigate to results
    if (_seconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rekaman ${_formatTime(_seconds)} selesai'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _cancelRecording() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Timer display
                  _buildTimerDisplay(isDark),

                  // Waveform visualization
                  Expanded(child: _buildWaveform(isDark)),

                  // Instructions and button
                  _buildActionArea(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_left,
                color: isDark ? AppColors.lightText : AppColors.darkText,
                size: 24,
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              'Rekam Suara',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Spacer for balance
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Timer container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.gray100,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _formatTime(_seconds),
              style: AppTextStyles.displayLarge.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Recording indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : AppColors.gray400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording ? 'RECORDING' : 'READY',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background glow
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale =
                1.0 + (0.1 * math.sin(_pulseController.value * 2 * math.pi));
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: _isRecording ? 0.2 : 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),

        // Waveform lines
        SizedBox(
          width: double.infinity,
          height: 128,
          child: CustomPaint(
            painter: WaveformPainter(
              animation: _waveController,
              isRecording: _isRecording,
              color: AppColors.primary,
            ),
          ),
        ),

        // Center line
        Container(
          width: double.infinity,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Silakan batuk di dekat mikrofon',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan lingkungan sekitar hening',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Record button
          GestureDetector(
            onTap: _toggleRecording,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow rings (when hovering/active)
                if (_isRecording) ...[
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.3),
                        child: Opacity(
                          opacity: 1.0 - _pulseController.value,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // Main button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? AppColors.primaryDark
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.15 : 0.4,
                        ),
                        blurRadius: 35,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: AppColors.darkText,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Cancel button
          TextButton(
            onPressed: _cancelRecording,
            child: Text(
              'Batal',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isRecording;
  final Color color;

  WaveformPainter({
    required this.animation,
    required this.isRecording,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: isRecording ? 0.8 : 0.4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    final amplitude = isRecording ? size.height * 0.35 : size.height * 0.15;
    final frequency = 0.02;
    final phase = animation.value * 2 * math.pi;

    path.moveTo(0, centerY);

    for (double x = 0; x <= size.width; x++) {
      final y =
          centerY +
          amplitude *
              math.sin(frequency * x + phase) *
              math.sin(x * 0.005 + phase * 0.5);
      path.lineTo(x, y);
    }

    // Draw gradient effect
    final gradient = LinearGradient(
      colors: [
        color.withValues(alpha: 0.1),
        color.withValues(alpha: isRecording ? 0.8 : 0.4),
        color.withValues(alpha: 0.1),
      ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawPath(path, paint);

    // Draw secondary wave
    final secondaryPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final secondaryPath = Path();
    secondaryPath.moveTo(0, centerY);

    for (double x = 0; x <= size.width; x++) {
      final y =
          centerY +
          (amplitude * 0.6) * math.sin(frequency * 1.5 * x + phase + 1);
      secondaryPath.lineTo(x, y);
    }

    secondaryPaint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawPath(secondaryPath, secondaryPaint);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      isRecording != oldDelegate.isRecording;
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
