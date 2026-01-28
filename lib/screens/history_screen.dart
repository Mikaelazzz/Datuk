import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/dashboard/bottom_nav_bar.dart';
import 'dashboard_screen.dart';

/// History Screen - shows diagnosis history
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavIndex = 1; // History is selected

  // Sample history data
  final List<HistoryGroup> _historyGroups = [
    HistoryGroup(
      month: 'Januari',
      year: '2024',
      items: [
        HistoryItem(
          day: '05',
          monthShort: 'Jan',
          title: 'Batuk Berdahak',
          time: '08:30 Pagi',
          icon: Icons.sick,
          iconColor: const Color(0xFFF97316),
          iconBgColor: const Color(0xFFFFF7ED),
          isRecent: true,
        ),
        HistoryItem(
          day: '02',
          monthShort: 'Jan',
          title: 'Flu Ringan',
          time: '14:15 Siang',
          icon: Icons.device_thermostat,
          iconColor: const Color(0xFFEAB308),
          iconBgColor: const Color(0xFFFEFCE8),
        ),
      ],
    ),
    HistoryGroup(
      month: 'Desember',
      year: '2023',
      items: [
        HistoryItem(
          day: '28',
          monthShort: 'Des',
          title: 'Batuk Kering',
          time: '07:15 Malam',
          icon: Icons.ac_unit,
          iconColor: const Color(0xFF3B82F6),
          iconBgColor: const Color(0xFFEFF6FF),
        ),
        HistoryItem(
          day: '15',
          monthShort: 'Des',
          title: 'Kondisi Membaik',
          time: '09:00 Pagi',
          icon: Icons.check_circle,
          iconColor: const Color(0xFF22C55E),
          iconBgColor: const Color(0xFFF0FDF4),
        ),
        HistoryItem(
          day: '02',
          monthShort: 'Des',
          title: 'Radang Tenggorokan',
          time: '10:45 Pagi',
          icon: Icons.emergency,
          iconColor: const Color(0xFFEF4444),
          iconBgColor: const Color(0xFFFEF2F2),
        ),
      ],
    ),
  ];

  void _onNavItemSelected(int index) {
    if (index == 0) {
      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      setState(() => _selectedNavIndex = index);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Search bar
            _buildSearchBar(isDark),

            // History list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _historyGroups.length,
                itemBuilder: (context, index) {
                  return _buildHistoryGroup(_historyGroups[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and title
          Row(
            children: [
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
                child: const Icon(
                  Icons.spa,
                  color: AppColors.darkText,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Riwayat',
                style: AppTextStyles.headingLarge.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Filter button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur filter akan segera hadir')),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
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
              child: Icon(
                Icons.filter_list,
                color: AppColors.gray500,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
          decoration: InputDecoration(
            hintText: 'Cari diagnosa atau tanggal...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.gray400, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryGroup(HistoryGroup group, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                '${group.month} ${group.year}',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.gray200,
                ),
              ),
            ],
          ),
        ),

        // History items
        ...group.items.map((item) => _buildHistoryCard(item, isDark)),
      ],
    );
  }

  Widget _buildHistoryCard(HistoryItem item, bool isDark) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to detail
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Detail: ${item.title}')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.isRecent
                    ? (isDark
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : const Color(0xFFD6FCE9))
                    : (isDark
                          ? Colors.grey.withValues(alpha: 0.1)
                          : const Color(0xFFF9FAFB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.monthShort.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.isRecent
                          ? AppColors.primaryDark
                          : AppColors.gray500,
                    ),
                  ),
                  Text(
                    item.day,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: item.isRecent
                          ? AppColors.primaryDark
                          : AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Title and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: AppColors.gray500),
                      const SizedBox(width: 4),
                      Text(
                        item.time,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? item.iconColor.withValues(alpha: 0.2)
                    : item.iconBgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? item.iconColor.withValues(alpha: 0.2)
                      : item.iconColor.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.iconColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model for history group (by month)
class HistoryGroup {
  final String month;
  final String year;
  final List<HistoryItem> items;

  HistoryGroup({required this.month, required this.year, required this.items});
}

/// Model for individual history item
class HistoryItem {
  final String day;
  final String monthShort;
  final String title;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isRecent;

  HistoryItem({
    required this.day,
    required this.monthShort,
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isRecent = false,
  });
}
