import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../models/announcement.dart';
import '../../services/mock/mock_data.dart';
import '../feed/widgets/announcement_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final prefs = ref.watch(preferencesProvider);
    final savedIds = prefs.savedAnnouncements;

    // Retrieve full Announcement models matching saved IDs from MockData (including expired ones)
    final savedAnnouncements = MockData.announcements
        .where((a) => savedIds.contains(a['id']))
        .map((a) => Announcement.fromMockMap(a))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslation(lang, 'savedAnnouncements')),
        automaticallyImplyLeading: false,
      ),
      body: savedAnnouncements.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.primaryEmerald.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_outline,
                        size: 44,
                        color: AppColors.accentGold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      getTranslation(lang, 'noSaved'),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white70 : AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: savedAnnouncements.length,
              itemBuilder: (context, index) {
                final a = savedAnnouncements[index];
                final now = DateTime.now();
                final isExpired = now.isAfter(a.expiresAt);

                return Stack(
                  children: [
                    AnnouncementCard(announcement: a),
                    
                    // Expired overlay banner
                    if (isExpired)
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              getTranslation(lang, 'ended').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: lang == 'ur' ? 'ہوم' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: lang == 'ur' ? 'ڈائریکٹری' : 'Explore',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark),
            label: getTranslation(lang, 'savedAnnouncements'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: lang == 'ur' ? 'ایڈمن' : 'Admin',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            context.go('/feed');
          } else if (index == 1) {
            context.push('/directory');
          } else if (index == 3) {
            context.push('/admin');
          }
        },
      ),
    );
  }
}
