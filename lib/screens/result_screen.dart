import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// Diagnostic Result Screen - shows the diagnosis result after AI processing
class ResultScreen extends StatelessWidget {
  final String diagnosisType;
  final String diagnosisDescription;
  final int accuracyPercent;

  const ResultScreen({
    super.key,
    this.diagnosisType = 'Batuk Kering',
    this.diagnosisDescription =
        'Batuk ini tidak menghasilkan dahak. Sering disebabkan oleh iritasi, alergi, atau tahap awal infeksi virus.',
    this.accuracyPercent = 94,
  });

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
            // Main content
            Column(
              children: [
                // Header
                _buildHeader(context, isDark),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Diagnosis Card
                        _buildDiagnosisCard(isDark),

                        const SizedBox(height: 24),

                        // Recommendations Section
                        _buildRecommendationsSection(isDark),

                        // Bottom spacing for footer buttons
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Footer buttons
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            'Hasil Diagnosa',
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Share button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur share akan segera hadir')),
              );
            },
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
                Icons.share,
                color: isDark ? AppColors.lightText : AppColors.darkText,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.5),
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
          // Background decoration
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Icon with accuracy badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      Icons.sick,
                      size: 48,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  // Accuracy badge
                  Positioned(
                    bottom: -12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF14532D).withValues(alpha: 0.5)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF166534)
                                : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFF15803D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$accuracyPercent% AKURAT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Diagnosis title
              Text(
                diagnosisType,
                style: AppTextStyles.headingLarge.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Diagnosis description
              Text(
                diagnosisDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Audio player
              _buildAudioPlayer(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF3F4F6),
        ),
      ),
      child: Row(
        children: [
          // Play button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),

          const SizedBox(width: 12),

          // Waveform visualization
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWaveBar(3, false),
                _buildWaveBar(5, false),
                _buildWaveBar(7, false),
                _buildWaveBar(4, false),
                _buildWaveBar(2, false),
                _buildWaveBar(6, false),
                _buildWaveBar(8, true),
                _buildWaveBar(5, false),
                _buildWaveBar(3, false),
                _buildWaveBar(2, false),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Duration
          Text(
            '0:05',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double heightFactor, bool isActive) {
    return Container(
      width: 4,
      height: heightFactor * 4,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryDark : AppColors.primary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildRecommendationsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(Icons.lightbulb, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Rekomendasi',
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Recommendations grid
        Row(
          children: [
            // Drink water
            Expanded(
              child: _buildRecommendationCard(
                icon: Icons.water_drop,
                iconColor: const Color(0xFF3B82F6),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Minum Air',
                description: 'Jaga hidrasi agar tenggorokan tidak kering.',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            // Rest
            Expanded(
              child: _buildRecommendationCard(
                icon: Icons.hotel,
                iconColor: const Color(0xFFF97316),
                iconBgColor: const Color(0xFFFFF7ED),
                title: 'Istirahat',
                description: 'Tidur minimal 7-8 jam untuk pemulihan.',
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Consult doctor - full width
        _buildDoctorRecommendationCard(isDark),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.2) : iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.gray400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorRecommendationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Konsultasi Dokter',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.gray300,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Disarankan jika batuk tidak membaik dalam 3 hari atau disertai demam.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gray400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Find doctor button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mencari dokter terdekat...')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Cari Dokter Terdekat',
                      style: AppTextStyles.buttonText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Re-record button
            GestureDetector(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: isDark ? AppColors.lightText : AppColors.gray400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rekam Ulang',
                      style: AppTextStyles.buttonText.copyWith(
                        color: isDark ? AppColors.lightText : AppColors.gray400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
