import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

/// Bottom sheet for selecting audio input method (record or upload)
class AudioInputSheet extends StatelessWidget {
  final VoidCallback onRecordTap;
  final VoidCallback onUploadTap;

  const AudioInputSheet({
    super.key,
    required this.onRecordTap,
    required this.onUploadTap,
  });

  /// Show the audio input bottom sheet
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRecordTap,
    required VoidCallback onUploadTap,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          AudioInputSheet(onRecordTap: onRecordTap, onUploadTap: onUploadTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Pilih Metode Input',
                style: AppTextStyles.headingLarge.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rekam suara batuk atau upload file audio',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Options
              Row(
                children: [
                  // Record option
                  Expanded(
                    child: _buildOptionCard(
                      context: context,
                      icon: Icons.mic,
                      title: 'Rekam',
                      subtitle: 'Rekam suara batuk langsung',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        onRecordTap();
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Upload option
                  Expanded(
                    child: _buildOptionCard(
                      context: context,
                      icon: Icons.upload_file,
                      title: 'Upload',
                      subtitle: 'Pilih file audio',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.pop(context);
                        onUploadTap();
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
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
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? color.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: AppTextStyles.headingMedium.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
