import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb and consolidateHttpClientResponseBytes
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import 'processing_screen.dart';

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

  // Audio recorder instance
  late final AudioRecorder _audioRecorder;
  String? _audioPath;
  Uint8List? _audioBytes; // For Web platform

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
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
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check and request permission
      if (await _audioRecorder.hasPermission()) {
        String? path;

        if (kIsWeb) {
          // Web: No path needed, record to memory/blob
          // Use WAV format for better compatibility
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: '', // Empty path for web blob recording
          );
          path = 'web_recording.wav'; // Placeholder name
        } else {
          // Native platforms: Use temporary directory
          final directory = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          path = '${directory.path}/recording_$timestamp.m4a';

          await _audioRecorder.start(const RecordConfig(), path: path);
        }

        setState(() {
          _isRecording = true;
          _audioPath = path;
          _seconds = 0;
        });

        _startTimer();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin mikrofon diperlukan untuk merekam.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memulai rekaman: $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      _stopTimer();
      final path = await _audioRecorder.stop();

      Uint8List? bytes;

      if (kIsWeb && path != null) {
        // On Web, path is a blob URL (e.g., blob:http://localhost:xxxxx/...)
        // We need to fetch the bytes from this blob URL using HTTP
        try {
          final response = await HttpClient()
              .getUrl(Uri.parse(path))
              .then((request) => request.close());
          final responseBytes = await consolidateHttpClientResponseBytes(
            response,
          );
          bytes = responseBytes;
        } catch (e) {
          debugPrint('Failed to fetch blob URL: $e');
          // Fallback: try using the http package
          try {
            final httpResponse = await http.get(Uri.parse(path));
            bytes = httpResponse.bodyBytes;
          } catch (e2) {
            debugPrint('HTTP fallback also failed: $e2');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal mengambil data rekaman: $e2')),
              );
            }
            return;
          }
        }
      }

      setState(() {
        _isRecording = false;
        _audioPath = path;
        _audioBytes = bytes;
      });

      // Navigate to processing screen if we have a recording
      if (mounted && (_audioPath != null || _audioBytes != null)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProcessingScreen(
              audioFilePath: _audioPath ?? 'web_recording.wav',
              audioBytes: _audioBytes,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghentikan rekaman: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _cancelRecording() async {
    _timer?.cancel();
    if (_isRecording) {
      await _audioRecorder.stop();
    }
    if (mounted) Navigator.pop(context);
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
                  _isRecording
                      ? 'Sedang Merekam...'
                      : 'Silakan batuk di dekat mikrofon',
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
            onPressed: () {
              if (_isRecording) {
                _cancelRecording();
              } else {
                Navigator.pop(context);
              }
            },
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
