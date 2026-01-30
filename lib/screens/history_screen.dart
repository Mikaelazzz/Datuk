import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/dashboard/bottom_nav_bar.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

/// History Screen - shows diagnosis history from database with pagination
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedNavIndex = 1; // History is selected

  // Pagination settings
  static const int _pageSize = 10; // Load 10 items at a time

  // State variables
  List<DiagnosisHistory> _allHistory = [];
  List<DiagnosisHistory> _filteredHistory = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _searchController.addListener(_filterHistory);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load more when user scrolls near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchHistory({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentOffset = 0;
        _hasMoreData = true;
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await ApiService.getHistory(limit: _pageSize);
      setState(() {
        _allHistory = history;
        _filteredHistory = history;
        _isLoading = false;
        _currentOffset = history.length;
        _hasMoreData = history.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData || _searchController.text.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Fetch next page by getting more items
      final moreHistory = await ApiService.getHistory(
        limit: _currentOffset + _pageSize,
      );

      // Get only the new items
      if (moreHistory.length > _allHistory.length) {
        final newItems = moreHistory.sublist(_allHistory.length);
        setState(() {
          _allHistory.addAll(newItems);
          _filteredHistory = _allHistory;
          _currentOffset = _allHistory.length;
          _hasMoreData = newItems.length >= _pageSize;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredHistory = _allHistory);
    } else {
      setState(() {
        _filteredHistory = _allHistory.where((item) {
          return item.jenisBatuk.toLowerCase().contains(query) ||
              item.formattedDate.toLowerCase().contains(query) ||
              item.monthName.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  /// Group history items by month and year
  List<_HistoryGroup> _groupHistoryByMonth() {
    if (_filteredHistory.isEmpty) return [];

    final Map<String, List<DiagnosisHistory>> grouped = {};

    for (final item in _filteredHistory) {
      final key = '${item.monthName}_${item.year}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped.entries.map((entry) {
      final parts = entry.key.split('_');
      return _HistoryGroup(month: parts[0], year: parts[1], items: entry.value);
    }).toList();
  }

  void _onNavItemSelected(int index) {
    if (index == 0) {
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
    _scrollController.dispose();
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

            // History list or loading/error state
            Expanded(child: _buildContent(isDark)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Memuat riwayat...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: AppColors.gray400),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat riwayat',
                style: AppTextStyles.headingMedium.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _fetchHistory(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Belum ada riwayat diagnosa'
                  : 'Tidak ada hasil ditemukan',
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Mulai diagnosa untuk melihat riwayat'
                  : 'Coba kata kunci lain',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
            ),
          ],
        ),
      );
    }

    final groups = _groupHistoryByMonth();

    return RefreshIndicator(
      onRefresh: () => _fetchHistory(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: groups.length + (_isLoadingMore || _hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at bottom
          if (index >= groups.length) {
            return _buildLoadMoreIndicator(isDark);
          }
          return _buildHistoryGroup(groups[index], isDark);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: _isLoadingMore
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Memuat lebih banyak...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              )
            : _hasMoreData
            ? GestureDetector(
                onTap: _loadMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.expand_more,
                        color: AppColors.gray500,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Muat lebih banyak',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Text(
                'Semua data telah dimuat',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray400,
                ),
              ),
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
              // Show count badge
              if (_allHistory.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_allHistory.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),

          // Refresh button
          GestureDetector(
            onTap: () => _fetchHistory(refresh: true),
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
              child: Icon(Icons.refresh, color: AppColors.gray500, size: 20),
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
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray400, size: 20),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
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

  Widget _buildHistoryGroup(_HistoryGroup group, bool isDark) {
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

        // History items with staggered animation
        ...group.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildHistoryCard(item, isDark),
          );
        }),
      ],
    );
  }

  Widget _buildHistoryCard(DiagnosisHistory item, bool isDark) {
    // Determine icon and colors based on diagnosis type
    final iconData = _getIconForDiagnosis(item.jenisBatuk);
    final iconColor = _getColorForDiagnosis(item.jenisBatuk);
    final iconBgColor = _getBgColorForDiagnosis(item.jenisBatuk);

    // Check if this is the most recent item
    final isRecent = _allHistory.isNotEmpty && _allHistory.first.id == item.id;

    return GestureDetector(
      onTap: () {
        _showDiagnosisDetail(item);
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
                color: isRecent
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
                      color: isRecent
                          ? AppColors.primaryDark
                          : AppColors.gray500,
                    ),
                  ),
                  Text(
                    item.day,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isRecent
                          ? AppColors.primaryDark
                          : AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Title, confidence, and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.jenisBatuk,
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Confidence badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.confidencePercent,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: AppColors.gray500),
                      const SizedBox(width: 4),
                      Text(
                        item.formattedTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      if (item.tingkatKondisi != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.trending_up,
                          size: 12,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.tingkatKondisi!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.2) : iconBgColor,
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

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
      return const Color(0xFFF97316); // Orange
    } else if (lower.contains('kering') || lower.contains('dry')) {
      return const Color(0xFF3B82F6); // Blue
    } else {
      return const Color(0xFF22C55E); // Green
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

  void _showDiagnosisDetail(DiagnosisHistory item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              item.jenisBatuk,
              style: AppTextStyles.headingLarge.copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Date and time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.gray400),
                const SizedBox(width: 8),
                Text(
                  '${item.formattedDate} ${item.year}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: AppColors.gray400),
                const SizedBox(width: 8),
                Text(
                  item.formattedTime,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Confidence
            _buildDetailRow(
              'Akurasi',
              item.confidencePercent,
              Icons.verified,
              AppColors.primary,
              isDark,
            ),
            const SizedBox(height: 12),

            // Severity level
            if (item.tingkatKondisi != null)
              _buildDetailRow(
                'Tingkat Kondisi',
                item.tingkatKondisi!,
                Icons.trending_up,
                const Color(0xFFF97316),
                isDark,
              ),
            const SizedBox(height: 24),

            // Recommendations
            if (item.rekomendasiObat != null &&
                item.rekomendasiObat!.isNotEmpty) ...[
              Text(
                'Rekomendasi Obat',
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...item.rekomendasiObat!.take(3).map((med) {
                if (med is Map<String, dynamic>) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medication,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            med['name']?.toString() ?? 'Unknown',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],

            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: isDark ? AppColors.lightText : AppColors.darkText,
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
}

/// Internal model for grouping history by month
class _HistoryGroup {
  final String month;
  final String year;
  final List<DiagnosisHistory> items;

  _HistoryGroup({required this.month, required this.year, required this.items});
}
