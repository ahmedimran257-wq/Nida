import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/scholar_provider.dart';
import '../../providers/feed_provider.dart';
import '../feed/widgets/announcement_card.dart';

class ScholarDetailScreen extends ConsumerWidget {
  final String scholarId;

  const ScholarDetailScreen({
    super.key,
    required this.scholarId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final prefs = ref.watch(preferencesProvider);
    final cityId = prefs.cityId ?? 'kurnool_in';

    final scholarAsync = ref.watch(scholarDetailsProvider(scholarId));
    final activeAnnouncementsAsync = ref.watch(activeAnnouncementsProvider(cityId));

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ur' ? 'عالمِ دین کا خاکہ' : 'Scholar Profile'),
      ),
      body: scholarAsync.when(
        data: (scholar) {
          if (scholar == null) {
            return Center(child: Text(lang == 'ur' ? 'معلومات دستیاب نہیں ہیں' : 'Scholar not found.'));
          }

          return CustomScrollView(
            slivers: [
              // Header card with Bio & Info
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border(
                      bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        lang == 'ur' || lang == 'ar' ? scholar.nameArabic : scholar.nameEnglish,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Specializations
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: scholar.specializations.map((spec) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primaryEmerald.withOpacity(0.2)),
                            ),
                            child: Text(
                              spec,
                              style: const TextStyle(
                                color: AppColors.primaryEmerald,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bio
                      if (scholar.bio.isNotEmpty) ...[
                        Text(
                          lang == 'ur' ? 'تعارف' : 'Biography',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          scholar.bio,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.textDark,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Section Header: Upcoming Programs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
                  child: Text(
                    lang == 'ur' ? 'آنے والے پروگرامات' : 'Upcoming Programs',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.accentGold : AppColors.primaryEmerald,
                    ),
                  ),
                ),
              ),
              
              // Upcoming programs feed list
              activeAnnouncementsAsync.when(
                data: (announcements) {
                  final scholarPrograms = announcements.where((a) => a.scholarId == scholar.id).toList();
                  
                  if (scholarPrograms.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          lang == 'ur' ? 'کوئی پروگرام طے نہیں ہے' : 'No scheduled programs for this scholar.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AnnouncementCard(announcement: scholarPrograms[index]);
                      },
                      childCount: scholarPrograms.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
