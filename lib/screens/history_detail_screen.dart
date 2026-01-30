import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/api_service.dart';

/// Detail screen for viewing a specific diagnosis history
class HistoryDetailScreen extends StatelessWidget {
  final DiagnosisHistory diagnosis;

  const HistoryDetailScreen({super.key, required this.diagnosis});

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
            _buildHeader(context, isDark),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diagnosis Type Card
                    _buildDiagnosisCard(isDark),
                    const SizedBox(height: 24),

                    // Stats Section
                    _buildStatsSection(isDark),
                    const SizedBox(height: 24),

                    // Description Section
                    _buildDescriptionSection(isDark),
                    const SizedBox(height: 24),

                    // Recommendations Section
                    if (diagnosis.rekomendasiObat != null &&
                        diagnosis.rekomendasiObat!.isNotEmpty)
                      _buildRecommendationsSection(isDark),

                    // Health Tips Section
                    const SizedBox(height: 24),
                    _buildHealthTipsSection(isDark),

                    // Warning Box
                    const SizedBox(height: 24),
                    _buildWarningBox(isDark),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Action Button
      bottomNavigationBar: _buildBottomAction(context, isDark),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? AppColors.lightText : AppColors.darkText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Riwayat',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${diagnosis.formattedDate} ${diagnosis.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),

          // Delete button (optional)
          GestureDetector(
            onTap: () => _showDeleteConfirmation(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(bool isDark) {
    final iconData = _getIconForDiagnosis(diagnosis.jenisBatuk);
    final iconColor = _getColorForDiagnosis(diagnosis.jenisBatuk);
    final iconBgColor = _getBgColorForDiagnosis(diagnosis.jenisBatuk);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withValues(alpha: 0.1),
            iconColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.2) : iconBgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(iconData, color: iconColor, size: 40),
          ),
          const SizedBox(height: 20),

          // Diagnosis title
          Text(
            diagnosis.jenisBatuk,
            style: AppTextStyles.headingLarge.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Date and time
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.gray400),
              const SizedBox(width: 6),
              Text(
                '${diagnosis.formattedDate} ${diagnosis.year}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule, size: 14, color: AppColors.gray400),
              const SizedBox(width: 6),
              Text(
                diagnosis.formattedTime,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Row(
      children: [
        // Confidence card
        Expanded(
          child: _buildStatCard(
            icon: Icons.verified,
            label: 'Akurasi',
            value: diagnosis.confidencePercent,
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),

        // Severity card
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Tingkat Kondisi',
            value: _getSeverityShort(diagnosis.tingkatKondisi),
            color: _getSeverityColor(diagnosis.tingkatKondisi),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.gray100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    final description = _getDiagnosisDescription(diagnosis.jenisBatuk);
    final symptoms = _getDiagnosisSymptoms(diagnosis.jenisBatuk);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.gray100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tentang Kondisi Ini',
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.lightText.withValues(alpha: 0.8)
                  : AppColors.gray600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // Symptoms
          Text(
            'Gejala Umum:',
            style: AppTextStyles.labelBold.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...symptoms.map(
            (symptom) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      symptom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.lightText.withValues(alpha: 0.8)
                            : AppColors.gray600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medication, color: AppColors.primaryDark, size: 20),
            const SizedBox(width: 8),
            Text(
              'Rekomendasi Obat',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...diagnosis.rekomendasiObat!.map((med) {
          if (med is Map<String, dynamic>) {
            final name = med['name']?.toString() ?? 'Unknown';
            final description = med['description']?.toString();
            final dose = med['dose']
                ?.toString(); // Changed from 'dosage' to 'dose'
            final priceRange = med['price_range']
                ?.toString(); // Changed from 'price' to 'price_range'
            final type = med['type']?.toString(); // Added type field

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with icon and name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medical_services,
                          color: AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.headingSmall.copyWith(
                                color: isDark
                                    ? AppColors.lightText
                                    : AppColors.darkText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (type != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: const Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Description
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray500,
                        height: 1.4,
                      ),
                    ),
                  ],

                  // Dose section
                  if (dose != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : AppColors.gray100.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Dosis',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dose,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Price section
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sell,
                          size: 16,
                          color: const Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          priceRange ?? 'Harga tidak tersedia',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF22C55E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildHealthTipsSection(bool isDark) {
    final healthTips = [
      {
        'icon': Icons.water_drop,
        'title': 'Perbanyak Minum Air Putih',
        'description':
            'Minum 8-10 gelas air putih per hari untuk menjaga tubuh tetap terhidrasi dan membantu mengencerkan dahak.',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.bedtime,
        'title': 'Istirahat yang Cukup',
        'description':
            'Tidur 7-9 jam per malam untuk membantu sistem imun tubuh melawan infeksi dan mempercepat pemulihan.',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.directions_run,
        'title': 'Olahraga Ringan',
        'description':
            'Lakukan olahraga ringan seperti jalan kaki atau peregangan untuk meningkatkan sirkulasi dan daya tahan tubuh.',
        'color': const Color(0xFF22C55E),
      },
      {
        'icon': Icons.restaurant,
        'title': 'Konsumsi Makanan Bergizi',
        'description':
            'Perbanyak buah, sayur, dan makanan kaya vitamin C untuk memperkuat sistem imun tubuh.',
        'color': const Color(0xFFF97316),
      },
      {
        'icon': Icons.masks,
        'title': 'Hindari Polusi & Asap',
        'description':
            'Gunakan masker saat beraktivitas di luar dan hindari paparan asap rokok atau polusi udara.',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.gray100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tips Menjaga Imun Tubuh',
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...healthTips.map((tip) {
            final icon = tip['icon'] as IconData;
            final title = tip['title'] as String;
            final description = tip['description'] as String;
            final color = tip['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.labelBold.copyWith(
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppTextStyles.bodySmall.copyWith(
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
          }),
        ],
      ),
    );
  }

  Widget _buildWarningBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFEF3C7),
            const Color(0xFFFDE68A).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peringatan',
                  style: AppTextStyles.labelBold.copyWith(
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hasil ini hanya bersifat prediksi. Segera konsultasikan ke dokter untuk diagnosis yang akurat.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF92400E),
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

  Widget _buildBottomAction(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Kembali ke Riwayat',
                  style: AppTextStyles.buttonText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Riwayat?',
          style: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        content: Text(
          'Riwayat diagnosa ini akan dihapus secara permanen.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.gray400)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await ApiService.deleteDiagnosis(diagnosis.id);
                if (context.mounted) {
                  Navigator.pop(
                    context,
                    true,
                  ); // Return to history with refresh flag
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Riwayat berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getIconForDiagnosis(String jenisBatuk) {
    final lower = jenisBatuk.toLowerCase();
    if (lower.contains('berdahak') || lower.contains('wet')) {
      return Icons.water_drop;
    } else if (lower.contains('kering') || lower.contains('dry')) {
      return Icons.air;
    } else {
      return Icons.healing;
    }
  }

  Color _getColorForDiagnosis(String jenisBatuk) {
    final lower = jenisBatuk.toLowerCase();
    if (lower.contains('berdahak') || lower.contains('wet')) {
      return const Color(0xFFF97316);
    } else if (lower.contains('kering') || lower.contains('dry')) {
      return const Color(0xFF3B82F6);
    } else {
      return const Color(0xFF22C55E);
    }
  }

  Color _getBgColorForDiagnosis(String jenisBatuk) {
    final lower = jenisBatuk.toLowerCase();
    if (lower.contains('berdahak') || lower.contains('wet')) {
      return const Color(0xFFFFF7ED);
    } else if (lower.contains('kering') || lower.contains('dry')) {
      return const Color(0xFFEFF6FF);
    } else {
      return const Color(0xFFF0FDF4);
    }
  }

  String _getSeverityShort(String? tingkat) {
    if (tingkat == null) return 'N/A';
    if (tingkat.contains('Lanjut')) return 'Lanjut';
    if (tingkat.contains('Sedang')) return 'Sedang';
    if (tingkat.contains('Ringan')) return 'Ringan';
    return tingkat;
  }

  Color _getSeverityColor(String? tingkat) {
    if (tingkat == null) return AppColors.gray400;
    if (tingkat.contains('Lanjut')) return Colors.red;
    if (tingkat.contains('Sedang')) return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }

  String _getDiagnosisDescription(String jenisBatuk) {
    final lower = jenisBatuk.toLowerCase();
    if (lower.contains('berdahak') || lower.contains('wet')) {
      return 'Batuk berdahak (produktif) adalah jenis batuk yang menghasilkan lendir atau dahak dari saluran pernapasan. Ini adalah mekanisme alami tubuh untuk membersihkan saluran napas dari zat asing, lendir, atau infeksi.';
    } else if (lower.contains('kering') || lower.contains('dry')) {
      return 'Batuk kering (non-produktif) adalah batuk yang tidak menghasilkan dahak atau lendir. Biasanya disebabkan oleh iritasi pada tenggorokan atau saluran napas bagian atas.';
    }
    return 'Kondisi pernapasan yang terdeteksi memerlukan pemeriksaan lebih lanjut untuk diagnosis yang lebih akurat.';
  }

  List<String> _getDiagnosisSymptoms(String jenisBatuk) {
    final lower = jenisBatuk.toLowerCase();
    if (lower.contains('berdahak') || lower.contains('wet')) {
      return [
        'Batuk yang mengeluarkan lendir/dahak',
        'Dahak berwarna bening, kuning, atau hijau',
        'Rasa tidak nyaman di dada',
        'Suara serak atau berlendir',
        'Hidung tersumbat atau berair',
      ];
    } else if (lower.contains('kering') || lower.contains('dry')) {
      return [
        'Batuk tanpa lendir atau dahak',
        'Tenggorokan terasa gatal atau kering',
        'Sensasi menggelitik di tenggorokan',
        'Batuk memburuk di malam hari',
        'Suara serak setelah batuk',
      ];
    }
    return [
      'Batuk persisten',
      'Ketidaknyamanan pada pernapasan',
      'Mungkin disertai gejala lain',
    ];
  }
}
