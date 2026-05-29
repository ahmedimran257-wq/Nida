import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../models/announcement.dart';
import '../../services/service_locator.dart';
import '../feed/widgets/announcement_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final prefs = ref.watch(preferencesProvider);
    final savedIds = prefs.savedAnnouncements;

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslation(lang, 'savedAnnouncements')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: FutureBuilder<List<Announcement>>(
        future: savedService.getSavedAnnouncements(savedIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final savedAnnouncements = snapshot.data ?? [];

          if (savedAnnouncements.isEmpty) {
            return Center(
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
            );
          }

          final active = savedAnnouncements.where((a) => a.expiresAt.isAfter(DateTime.now())).toList();
          final ended = savedAnnouncements.where((a) => a.expiresAt.isBefore(DateTime.now())).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (active.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    lang == 'ur' ? 'سرگرم پروگرام' : 'Active Programs',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
                ...active.map((a) => AnnouncementCard(announcement: a)),
              ],
              if (ended.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                  child: Text(
                    lang == 'ur' ? 'سابقہ پروگرام' : 'Past Programs',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...ended.map((a) => Stack(
                      children: [
                        AnnouncementCard(announcement: a),
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.85),
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
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}
