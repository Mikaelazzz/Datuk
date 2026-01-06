import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// Social proof section with avatars and user count
class SocialProof extends StatelessWidget {
  const SocialProof({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Text(
            'Trusted by 10,000+ happy minds',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAd3I1-u_erxGPUBJbE3qPTeTZgfXY2qLYkOmbk6PYESB8y6ca_y1jI7T31Sq7uQD7Hfmf_8PB3lwMjYyVvOZ1ajeqC8R6o_XhdLL-Ie1DgEXonGXL_dRBpAFXlNvXAxSmDyKLzk2yn-KSBXBZqEUFGh8RDYJEsOxOlsqcLRilmpfc2AGQsc6ZHdH8FfF42JJc7IKOgLtIaezZu7RUNnD8qT2avMj8NB6Vv7LYgZnj0R9koL6WlnxiX638jnIDDhBYYeksOkqEW_B5l',
                isDark,
              ),
              _buildAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDNDXmWqJaGPW5lovuL-Z9KoxwhuQPkaTASCW54GecoDcQR0WKA_o2yV7we4QCTnt6D_BLu_3J2dgne02gnl6wR-ErRzIn8mcc6GVBRgVKNDQDEpAna-tEV76JhupJC01VDpw9zwURnTF0lvaun-oDcnt12tHhz3AhUhJWicsHech9LNJIJ7pTO4BJYBJGCmQiThQPyH4S9xGF0Wsxs66UQF9I-IekRwhv3-hSVdBe3o1wRXgAO8f6s8kTRnUjSMcOVphiJfR6T65m8',
                isDark,
              ),
              _buildAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCIJO9-7FD863GkNxSMk1T56-AxmWNbIrS32ZulGQxpgIZmoPiiDHiOFrhZptn3Wcm1Ax1MGdt4tolaE9okmKZz075DAmeccj3tiL996xP2lV-QRbq_XcmeNlxRsQBj_wW63zZkayoe41FXy4tv16Rf-iXVHbJ7YHxvyWqHMa5HIoSQzSk2zhUkLgFWBtAnSk2DeO5bmUOs2lTu424rWDlv2IZ8FwBYOvGrCa5c85AQyh2AHtD7ukg7fVkqegC4gAxeO_seIoYz7Cqb',
                isDark,
              ),
              _buildAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAwYI7ilZv0YuVN40YO1gqMKslgrPYtDwRvjRej2JzDrkMtTB7cNoZ_uyKBeta76DH61nAH9GmX4jcZvV8ht0LZHYY6wvtqEtUd3TvfIbcaQrHhOfxvu_3wTjxnn0TW6S5KJX4K8EF5IxfKMO86qnSPVlthDCZ5qoWhfwNRZ20m8yTCaZOvvx9y7KWUHVWPVRpfjI5jThlvAqHjib_1kD2tFU5IBw6bpE0FUFO3T_WyD3PspyACgZ7_MpjS1J9KCUIsdmGi4tmr_E9o',
                isDark,
              ),
              _buildCountBadge(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0),
      transform: Matrix4.translationValues(-8, 0, 0),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
            width: 2,
          ),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 0),
      transform: Matrix4.translationValues(-8, 0, 0),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : AppColors.gray100,
        border: Border.all(
          color: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '+9k',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontWeight: FontWeight.w700,
            fontSize: 8,
          ),
        ),
      ),
    );
  }
}
