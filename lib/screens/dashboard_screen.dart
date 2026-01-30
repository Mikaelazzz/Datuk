import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/dashboard/diagnose_button.dart';
import '../widgets/dashboard/history_item.dart';
import '../widgets/dashboard/bottom_nav_bar.dart';
import '../widgets/dashboard/audio_input_sheet.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import 'recording_screen.dart';
import 'processing_screen.dart';
import 'history_screen.dart';
import 'history_detail_screen.dart';
import '../services/websocket_service.dart';
import 'dart:async';

/// Dashboard screen - main screen after starting session
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  // History state
  List<DiagnosisHistory> _recentHistory = [];
  bool _isLoadingHistory = true;

  // WebSocket
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchRecentHistory();
    _initWebSocket();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }

  void _initWebSocket() {
    _wsService.connect();
    _wsSubscription = _wsService.eventStream.listen((event) {
      final type = event['type'] as String?;
      if (type == 'new_diagnosis' || type == 'diagnosis_deleted') {
        // Refresh history when new diagnosis or deletion occurs
        _fetchRecentHistory();
      }
    });
  }

  Future<void> _fetchRecentHistory() async {
    try {
      final history = await ApiService.getHistory(limit: 3);
      if (mounted) {
        setState(() {
          _recentHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

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
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProcessingScreen(
                  audioFilePath: audioFile.path ?? audioFile.name,
                  audioBytes: audioFile.bytes,
                ),
              ),
            );
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
        child: Column(
          children: [
            // Main content - Expanded to fill available space
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(isDark),

                    // Diagnose Button Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: DiagnoseButton(
                          onPressed: () => _showAudioInputOptions(context),
                        ),
                      ),
                    ),

                    // History Section
                    _buildHistorySection(isDark),

                    // Bottom spacing
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Navigation - Fixed at bottom
            BottomNavBar(
              selectedIndex: _selectedNavIndex,
              onItemSelected: (index) {
                if (index == 1) {
                  // Navigate to history screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                } else {
                  setState(() {
                    _selectedNavIndex = index;
                  });
                }
              },
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
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
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
            child: const Icon(Icons.spa, color: AppColors.darkText, size: 24),
          ),
          const SizedBox(width: 12),

          // App name
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
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

          // History Items from API
          _buildHistoryContent(isDark),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(bool isDark) {
    if (_isLoadingHistory) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_recentHistory.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.gray100,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 48, color: AppColors.gray400),
            const SizedBox(height: 12),
            Text(
              'Belum ada riwayat',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mulai diagnosa untuk melihat riwayat',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentHistory.map((item) {
        // Determine icon based on diagnosis type
        IconData icon;
        Color iconColor;
        Color iconBgColor;

        final jenisBatuk = item.jenisBatuk.toLowerCase();

        if (jenisBatuk.contains('berdahak') || jenisBatuk.contains('wet')) {
          icon = Icons.water_drop;
          iconColor = const Color(0xFFF97316);
          iconBgColor = const Color(0xFFFFF7ED);
        } else if (jenisBatuk.contains('kering') ||
            jenisBatuk.contains('dry')) {
          icon = Icons.air;
          iconColor = const Color(0xFF3B82F6);
          iconBgColor = const Color(0xFFEFF6FF);
        } else {
          icon = Icons.check_circle;
          iconColor = AppColors.primaryDark;
          iconBgColor = AppColors.primary.withValues(alpha: 0.1);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryDetailScreen(diagnosis: item),
                ),
              );
              // Refresh if item was deleted
              if (result == true) {
                _fetchRecentHistory();
              }
            },
            child: HistoryItem(
              icon: icon,
              iconBackgroundColor: iconBgColor,
              iconColor: iconColor,
              title: item.jenisBatuk,
              subtitle: '${item.formattedDate} • ${item.formattedTime}',
              showBadge: false, // Hide badge on dashboard
            ),
          ),
        );
      }).toList(),
    );
  }
}
