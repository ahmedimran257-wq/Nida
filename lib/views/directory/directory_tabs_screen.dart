import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/masjid_provider.dart';
import '../../providers/scholar_provider.dart';
import '../feed/widgets/announcement_card.dart';

class DirectoryTabsScreen extends ConsumerStatefulWidget {
  const DirectoryTabsScreen({super.key});

  @override
  ConsumerState<DirectoryTabsScreen> createState() => _DirectoryTabsScreenState();
}

class _DirectoryTabsScreenState extends ConsumerState<DirectoryTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final prefs = ref.watch(preferencesProvider);
    final cityId = prefs.cityId ?? 'kurnool_in';

    final masjidsAsync = ref.watch(masjidsProvider(cityId));
    final scholarsAsync = ref.watch(scholarsProvider(cityId));

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ur' ? 'ڈائریکٹری' : 'Explore Community'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          labelColor: AppColors.accentGold,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: getTranslation(lang, 'masjids')),
            Tab(text: getTranslation(lang, 'scholars')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Directory Search Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: _tabController.index == 0
                    ? (lang == 'ur' ? 'مسجد کا نام تلاش کریں...' : 'Search masjid name or locality...')
                    : (lang == 'ur' ? 'عالم دین تلاش کریں...' : 'Search scholar by name...'),
                prefixIcon: const Icon(Icons.search, color: AppColors.accentGold),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Masjids List Tab
                masjidsAsync.when(
                  data: (masjids) {
                    final filtered = masjids.where((m) =>
                        m.nameEnglish.toLowerCase().contains(_searchQuery) ||
                        m.nameArabic.contains(_searchQuery) ||
                        m.locality.toLowerCase().contains(_searchQuery)).toList();
                        
                    if (filtered.isEmpty) {
                      return Center(child: Text(lang == 'ur' ? 'کوئی مساجد نہیں ملیں' : 'No masjids found.'));
                    }
                    
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final m = filtered[index];
                        final isFollowing = ref.watch(isFollowingMasjidProvider(m.id));
                        
                        return Card(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Row(
                              children: [
                                Text(
                                  lang == 'ur' || lang == 'ar' ? m.nameArabic : m.nameEnglish,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                if (m.isVerified)
                                  const CustomPaint(
                                    size: Size(12, 12),
                                    painter: OctagonalSealPainter(color: AppColors.accentGold),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text('${m.locality} · ${m.followerCount} ${lang == 'ur' ? 'فالوورز' : 'followers'}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                ref.read(masjidFollowActionProvider).toggleFollow(m.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing ? Colors.grey.withOpacity(0.2) : AppColors.primaryEmerald,
                                foregroundColor: isFollowing ? (isDark ? Colors.white : Colors.black87) : Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Text(
                                isFollowing ? getTranslation(lang, 'following') : getTranslation(lang, 'follow'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () => context.push('/masjid/${m.id}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
                
                // 2. Scholars List Tab
                scholarsAsync.when(
                  data: (scholars) {
                    final filtered = scholars.where((s) =>
                        s.nameEnglish.toLowerCase().contains(_searchQuery) ||
                        s.nameArabic.contains(_searchQuery)).toList();
                        
                    if (filtered.isEmpty) {
                      return Center(child: Text(lang == 'ur' ? 'کوئی علماء نہیں ملے' : 'No scholars found.'));
                    }
                    
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        return Card(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              lang == 'ur' || lang == 'ar' ? s.nameArabic : s.nameEnglish,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: s.specializations.map((spec) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white12 : Colors.black.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(spec, style: const TextStyle(fontSize: 10)),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () => context.push('/scholar/${s.id}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
