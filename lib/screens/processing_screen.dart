import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

/// AI Processing screen - shows while analyzing the cough recording
class ProcessingScreen extends StatefulWidget {
  final String? audioFilePath;
  final Uint8List? audioBytes;

  const ProcessingScreen({super.key, this.audioFilePath, this.audioBytes});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;
  double _progress = 0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Start processing after frame is built to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAudio();
    });
  }

  Future<void> _processAudio() async {
    // Start fake progress for visual feedback while uploading
    _startProgressSimulation();

    if (widget.audioFilePath == null && widget.audioBytes == null) {
      // Modified this line
      _showError("File audio tidak ditemukan");
      return;
    }

    try {
      // Use centralized API base URL from ApiService
      final uri = Uri.parse('${ApiService.baseUrl}/predict');
      debugPrint('Connecting to API at: $uri');

      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        if (widget.audioBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              widget.audioBytes!,
              filename: 'audio.wav', // Default name for blob
            ),
          );
        } else {
          _showError("Web Upload gagal: File bytes kosong.");
          return;
        }
      } else {
        // Native: Use fromPath
        if (widget.audioFilePath != null) {
          // Added null check for audioFilePath
          final file = File(widget.audioFilePath!);
          if (await file.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath('file', widget.audioFilePath!),
            );
          } else {
            throw Exception("File not found at path: ${widget.audioFilePath}");
          }
        } else {
          throw Exception(
            "File path is null on native platform",
          ); // Added error for null path
        }
      }

      debugPrint('Uploading to $uri...');
      // Send valid request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Koneksi ke server timeout (30s). Pastikan server backend berjalan.',
          );
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Boost progress to 100%
        _progressTimer?.cancel();
        setState(() => _progress = 100);

        // Wait a small moment for animation
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // Parse recommendations safely
          List<dynamic> rawRecs = data['recommendations'] ?? [];
          List<Map<String, dynamic>> medicines =
              List<Map<String, dynamic>>.from(rawRecs);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                diagnosisType: data['prediction'] ?? 'Tidak Diketahui',
                diagnosisSubtitle:
                    'Tingkat Kondisi: ${data['analysis'] ?? 'Normal'}',
                diagnosisDescription: data['message'] ?? 'Analisa selesai.',
                accuracyPercent: ((data['confidence'] ?? 0.0) * 100).toInt(),
                recommendations: medicines,
              ),
            ),
          );
        }
      } else {
        _showError(
          "Gagal menganalisa (Server ${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      debugPrint('Error uploading: $e');
      _showError(
        "Terjadi kesalahan koneksi to backend. Pastikan server berjalan dan alamat benar. Error: $e",
      );
    }
  }

  void _showError(String message) {
    _progressTimer?.cancel();
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Gagal Menganalisa'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to dashboard
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      );
    }
  }

  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Don't reach 100% automatically, wait for API
      if (_progress >= 90) {
        return;
      }
      setState(() {
        _progress += (math.Random().nextDouble() * 2) + 0.5;
        if (_progress > 90) _progress = 90;
      });
    });
  }

  // Removed _onProcessingComplete as it is now handled in _processAudio logic

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Background blurs
            _buildBackgroundEffects(isDark),

            // Main content
            Column(
              children: [
                // Header
                _buildHeader(isDark),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // AI Robot icon
                        _buildRobotIcon(isDark),

                        const SizedBox(height: 48),

                        // Status and text
                        _buildStatusSection(isDark),

                        const SizedBox(height: 48),

                        // Progress bar
                        _buildProgressBar(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects(bool isDark) {
    return Stack(
      children: [
        // Top center blur
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        // Bottom right blur
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.2,
          right: -50,
          child: Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryDark.withValues(alpha: 0.2)
                  : const Color(0xFFD1FAE5).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
                Icons.arrow_back_ios_new,
                color: isDark ? AppColors.lightText : AppColors.darkText,
                size: 18,
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              'Analisa AI',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Spacer
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildRobotIcon(bool isDark) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = 10 * math.sin(_floatController.value * math.pi);
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Outer glow
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(48),
                ),
              ),

              // Main container
              Container(
                width: 192,
                height: 192,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [AppColors.surfaceDark, Colors.black]
                        : [Colors.white, const Color(0xFFD1FAE5)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Top highlight
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                      ),
                    ),

                    // Robot icon
                    Center(
                      child: Icon(
                        Icons.smart_toy,
                        size: 96,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Medical badge (top right)
              Positioned(
                top: -8,
                right: -8,
                child: _buildBounceAnimation(
                  delay: 0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Check badge (bottom left)
              Positioned(
                bottom: -4,
                left: -4,
                child: _buildBounceAnimation(
                  delay: 0.5,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBounceAnimation({required double delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 3000 + (delay * 1000).toInt()),
      builder: (context, value, _) {
        final bounce = math.sin(value * math.pi * 2) * 4;
        return Transform.translate(offset: Offset(0, bounce), child: child);
      },
    );
  }

  Widget _buildStatusSection(bool isDark) {
    return Column(
      children: [
        // Processing badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing dot
              Stack(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: 1 + (_shimmerController.value * 0.5),
                        child: Opacity(
                          opacity: 1 - _shimmerController.value,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                'SEDANG MEMPROSES',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          'AI sedang menganalisa\njenis batukmu...',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLarge.copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        Text(
          'Kami sedang mencocokkan pola suara\ndengan database medis kami.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gray400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analisa Spektrum',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_progress.toInt()}%',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  // Progress fill - aligned to left for left-to-right filling
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 280 * (_progress / 100),
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Shimmer effect - only on filled portion
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 280 * (_progress / 100),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          final shimmerWidth = 60.0;
                          final progressWidth = 280 * (_progress / 100);
                          return Transform.translate(
                            offset: Offset(
                              -shimmerWidth +
                                  (_shimmerController.value *
                                      (progressWidth + shimmerWidth)),
                              0,
                            ),
                            child: Container(
                              width: shimmerWidth,
                              height: 16,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Estimated time
          Text(
            'Estimasi waktu: ~${(5 - (_progress / 20)).toInt().clamp(1, 5)} detik',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
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
