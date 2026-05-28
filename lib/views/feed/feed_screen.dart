import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/feed_provider.dart';
import 'widgets/announcement_card.dart';
import 'widgets/live_now_row.dart';
import 'widgets/filter_chips.dart';
import 'search_overlay.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(String cityId) async {
    _refreshController.repeat();
    // Invalidate/refresh active announcements
    ref.invalidate(activeAnnouncementsProvider(cityId));
    await Future.delayed(const Duration(milliseconds: 1200));
    _refreshController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocale = ref.watch(localeProvider);
    final lang = selectedLocale.languageCode;
    final prefs = ref.watch(preferencesProvider);
    final cityId = prefs.cityId ?? 'kurnool_in';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get city details for header name display
    final cityName = cityId.split('_').first;
    final formattedCityName = cityName[0].toUpperCase() + cityName.substring(1);

    final selectedTab = ref.watch(feedTabSelectionProvider);
    final groupedFeedAsync = ref.watch(groupedFeedProvider(cityId));
    final liveProgramsAsync = ref.watch(liveAnnouncementsProvider(cityId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslation(lang, 'appName') == 'NIDA' ? 'NIDA · نداء' : 'نداء · NIDA',
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push('/settings'),
        ),
        actions: [
          // City Picker Pill
          GestureDetector(
            onTap: () => context.push('/city-search'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.accentGold),
                  const SizedBox(width: 4),
                  Text(
                    formattedCityName,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchOverlay(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selection ("For You" and "All")
          Container(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTabButton(0, getTranslation(lang, 'forYou'), selectedTab),
                    _buildTabButton(1, getTranslation(lang, 'all'), selectedTab),
                  ],
                ),
                // Category Filter Scrollable Chips
                const FilterChips(),
              ],
            ),
          ),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _handleRefresh(cityId),
              color: AppColors.accentGold,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              child: CustomScrollView(
                slivers: [
                  // Live Now Section (horizontal row)
                  liveProgramsAsync.when(
                    data: (liveList) {
                      if (liveList.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                      return SliverToBoxAdapter(
                        child: LiveNowRow(announcements: liveList),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),

                  // For You Empty State Check
                  if (selectedTab == 0 && prefs.followedMasjids.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.bookmark_border, size: 48, color: AppColors.accentGold),
                                  const SizedBox(height: 16),
                                  Text(
                                    getTranslation(lang, 'noFollows'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Switch bottom bar navigation to Directory
                                      // Or push directly to directory view
                                      context.push('/directory');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryEmerald,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(lang == 'ur' ? 'مساجد تلاش کریں' : 'Browse Masjids'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Main announcement lists grouped by time sections
                    groupedFeedAsync.when(
                      data: (grouped) {
                        if (grouped.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                lang == 'ur' ? 'کوئی پروگرام دستیاب نہیں ہے' : 'No upcoming programs scheduled.',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            if (grouped.today.isNotEmpty) ...[
                              _buildSectionHeader(getTranslation(lang, 'today')),
                              ...grouped.today.map((a) => AnnouncementCard(announcement: a)),
                            ],
                            if (grouped.tomorrow.isNotEmpty) ...[
                              _buildSectionHeader(getTranslation(lang, 'tomorrow')),
                              ...grouped.tomorrow.map((a) => AnnouncementCard(announcement: a)),
                            ],
                            if (grouped.thisWeek.isNotEmpty) ...[
                              _buildSectionHeader(lang == 'ur' ? 'اس ہفتے' : 'This Week'),
                              ...grouped.thisWeek.map((a) => AnnouncementCard(announcement: a)),
                            ],
                            if (grouped.comingUp.isNotEmpty) ...[
                              _buildSectionHeader(getTranslation(lang, 'comingUp')),
                              ...grouped.comingUp.map((a) => AnnouncementCard(announcement: a)),
                            ],
                            const SizedBox(height: 32),
                          ]),
                        );
                      },
                      loading: () => SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildShimmerCard(isDark),
                          childCount: 3,
                        ),
                      ),
                      error: (err, stack) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('Error: $err')),
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

  Widget _buildTabButton(int index, String label, int selectedIndex) {
    final isSelected = index == selectedIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(feedTabSelectionProvider.notifier).state = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.accentGold : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? (isDark ? AppColors.accentGold : AppColors.primaryEmerald)
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.accentGold,
        ),
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 160,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 14,
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 18,
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 14,
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 20,
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
