import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/dashboard/status_card.dart';
import '../widgets/dashboard/diagnose_button.dart';
import '../widgets/dashboard/history_item.dart';
import '../widgets/dashboard/bottom_nav_bar.dart';
import '../widgets/dashboard/audio_input_sheet.dart';
import '../services/audio_service.dart';
import 'recording_screen.dart';
import 'processing_screen.dart';

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
        // Navigate to recording screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecordingScreen()),
        );
      },
      onUploadTap: () async {
        // Handle upload action
        final audioFile = await AudioService.pickAudioFile(context);
        if (audioFile != null && context.mounted) {
          // Navigate to processing screen with the audio file
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProcessingScreen(audioFilePath: audioFile.name),
            ),
          );
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
