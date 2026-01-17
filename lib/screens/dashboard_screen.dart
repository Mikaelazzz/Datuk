import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/dashboard/status_card.dart';
import '../widgets/dashboard/diagnose_button.dart';
import '../widgets/dashboard/history_item.dart';
import '../widgets/dashboard/bottom_nav_bar.dart';
import '../widgets/dashboard/audio_input_sheet.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';

/// Dashboard screen - main screen after starting session
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  /// Show audio input options (Record or Upload)
  void _showAudioInputOptions(BuildContext context) {
    AudioInputSheet.show(
      context,
      onRecordTap: () {
        // Handle record action
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memulai perekaman batuk...'),
            backgroundColor: Color(0xFF42f099),
            duration: Duration(seconds: 2),
          ),
        );
        // TODO: Implement recording functionality
      },
      onUploadTap: () async {
        // Handle upload action
        final filePath = await AudioService.pickAudioFile(context);
        if (filePath != null) {
          if (!AudioService.isValidAudioFormat(filePath)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Format file tidak didukung. Gunakan MP3, WAV, atau M4A.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final fileName = AudioService.getFileName(filePath);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File "$fileName" berhasil dipilih'),
                backgroundColor: const Color(0xFF42f099),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          // Show loading snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menganalisis audio...'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 1),
              ),
            );
          }

          try {
            final result = await ApiService.predictCough(filePath);
            

            if (context.mounted) {
              // Show result dialog
              showDialog(
                context: context,
                builder: (context) {
                  final recommendations = result['recommendations'] as List?;
                  
                  return AlertDialog(
                    title: const Text('Hasil Analisis'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Result Section
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (result['prediction'] == 'Batuk berdahak') 
                                    ? Colors.orange.withValues(alpha: 0.1)
                                    : Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Jenis Batuk:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  Text(
                                    result['prediction'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: (result['prediction'] == 'Batuk berdahak') 
                                          ? Colors.orange[800]
                                          : Colors.blue[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Akurasi: ${(result['confidence'] * 100).toStringAsFixed(1)}%'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Recommendations Section
                            if (recommendations != null && recommendations.isNotEmpty) ...[
                              const Text(
                                'Rekomendasi Obat (RAG):',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              ...recommendations.map((med) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                color: Colors.grey[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med['name'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(med['description'], style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Dosis: ${med['dose']}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ],
                            
                            const SizedBox(height: 16),
                            Text('File: ${result['file']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  );
                },
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
    );
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
            // Main content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(isDark),

                  // Status Card
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: StatusCard(),
                  ),

                  // Diagnose Button Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: DiagnoseButton(
                        onPressed: () => _showAudioInputOptions(context),
                      ),
                    ),
                  ),

                  // History Section
                  _buildHistorySection(isDark),

                  // Bottom spacing for nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                selectedIndex: _selectedNavIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedNavIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.9)
            : AppColors.backgroundLight.withValues(alpha: 0.9),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
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
            child: const Icon(Icons.spa, color: AppColors.darkText, size: 18),
          ),
          const SizedBox(width: 8),
          // Title
          Text(
            'Datuk',
            style: AppTextStyles.headingLarge.copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Terakhir',
                style: AppTextStyles.headingMedium.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // History Items
          const HistoryItem(
            icon: Icons.sick,
            iconBackgroundColor: Color(0xFFFFF7ED),
            iconColor: Color(0xFFF97316),
            title: 'Batuk Berdahak',
            subtitle: '2 Jan • 08:30 Pagi',
            badgeText: 'Rawat',
            badgeBackgroundColor: Color(0xFFFFEDD5),
            badgeTextColor: Color(0xFFEA580C),
          ),
          const SizedBox(height: 12),

          const HistoryItem(
            icon: Icons.ac_unit,
            iconBackgroundColor: Color(0xFFEFF6FF),
            iconColor: Color(0xFF3B82F6),
            title: 'Batuk Kering',
            subtitle: '28 Des • 07:15 Malam',
            badgeText: 'Pantau',
            badgeBackgroundColor: Color(0xFFDBEAFE),
            badgeTextColor: Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),

          HistoryItem(
            icon: Icons.check_circle,
            iconBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
            iconColor: AppColors.primaryDark,
            title: 'Kondisi Membaik',
            subtitle: '15 Des • 09:00 Pagi',
            badgeText: 'Sehat',
            badgeBackgroundColor: AppColors.primary.withValues(alpha: 0.2),
            badgeTextColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }
}
