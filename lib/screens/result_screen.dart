import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import 'dashboard_screen.dart';

/// Diagnostic Result Screen - shows the diagnosis result after AI processing
class ResultScreen extends StatelessWidget {
  final String diagnosisType;
  final String diagnosisSubtitle;
  final String diagnosisDescription;
  final int accuracyPercent;
  final List<dynamic> recommendations;

  const ResultScreen({
    super.key,
    this.diagnosisType = 'Batuk Kering',
    this.diagnosisSubtitle = '(Dry Cough)',
    this.diagnosisDescription =
        'Batuk jenis ini tidak menghasilkan dahak atau lendir. Sering disebabkan oleh iritasi tenggorokan, alergi, atau tahap awal infeksi virus ringan.',
    this.accuracyPercent = 94,
    this.recommendations = const [],
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
                        const SizedBox(height: 16),

                        // Diagnosis Card
                        _buildDiagnosisCard(isDark),

                        const SizedBox(height: 32),

                        // Warning Box
                        _buildWarningBox(isDark),

                        const SizedBox(height: 16),

                        // Recommendations Section
                        _buildRecommendationsSection(context, isDark),

                        // Bottom spacing for footer buttons - increased from 160
                        const SizedBox(height: 120),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? AppColors.lightText : AppColors.darkText,
                size: 20,
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

          // Empty spacer for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            right: -32,
            top: -32,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Accuracy badge and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Accuracy badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$accuracyPercent% Akurasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Diagnosis title
                        Text(
                          diagnosisType,
                          style: AppTextStyles.headingLarge.copyWith(
                            fontSize: 28,
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Subtitle
                        Text(
                          diagnosisSubtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [const Color(0xFF98FFD8), AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    transform: Matrix4.rotationZ(0.05),
                    child: const Icon(Icons.air, size: 32, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark.withValues(alpha: 0.5)
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.gray100,
                  ),
                ),
                child: Text(
                  diagnosisDescription,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MEDICINE RECOMMENDATIONS (FROM API)
        if (recommendations.isNotEmpty) ...[
          Text(
            'Rekomendasi Obat',
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final med = recommendations[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF9FAFB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medication,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med['name'] ?? 'Nama Obat',
                            style: AppTextStyles.headingSmall.copyWith(
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            med['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            med['price_range'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],

        // HEALING RECOMMENDATIONS (STATIC)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saran Penyembuhan',
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2x2 Grid of healing recommendations
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildRecommendationCard(
              icon: Icons.water_drop,
              iconColor: const Color(0xFF0284C7),
              iconBgColor: const Color(0xFFE0F2FE),
              title: 'Minum Air',
              subtitle: 'Jaga hidrasi leher',
              isDark: isDark,
            ),
            _buildRecommendationCard(
              icon: Icons.bedtime,
              iconColor: const Color(0xFF7E22CE),
              iconBgColor: const Color(0xFFF3E8FF),
              title: 'Istirahat',
              subtitle: '7-8 jam per hari',
              isDark: isDark,
            ),
            _buildRecommendationCard(
              icon: Icons.coffee,
              iconColor: const Color(0xFFC2410C),
              iconBgColor: const Color(0xFFFFEDD5),
              title: 'Teh Hangat',
              subtitle: 'Redakan iritasi',
              isDark: isDark,
            ),
            _buildRecommendationCard(
              icon: Icons.medical_services,
              iconColor: AppColors.primaryDark,
              iconBgColor: AppColors.primary.withValues(alpha: 0.1),
              title: 'Konsultasi',
              subtitle: 'Jika berlanjut',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
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
              : const Color(0xFFF9FAFB),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.2) : iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.gray400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF854D0E).withValues(alpha: 0.2)
            : const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF854D0E).withValues(alpha: 0.3)
              : const Color(0xFFFEF08A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? const Color(0xFFFACC15) : const Color(0xFFCA8A04),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hasil ini berdasarkan analisa AI dan bukan diagnosa medis final. Segera ke dokter jika mengalami sesak napas.',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFFFEF9C3)
                    : const Color(0xFF854D0E),
                height: 1.5,
              ),
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
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.gray100,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Re-record button
            GestureDetector(
              onTap: () {
                // Navigate to DashboardScreen (Mulai Diagnosa page)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.gray600 : AppColors.gray200,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.replay,
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rekam Ulang',
                      style: AppTextStyles.buttonText.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
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
