import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/masjid_provider.dart';
import '../../providers/feed_provider.dart';
import '../feed/widgets/announcement_card.dart';

class MasjidDetailScreen extends ConsumerWidget {
  final String masjidId;

  const MasjidDetailScreen({
    super.key,
    required this.masjidId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final prefs = ref.watch(preferencesProvider);
    final cityId = prefs.cityId ?? 'kurnool_in';

    // Watch masjids list to find matching masjid details
    final masjidsAsync = ref.watch(masjidsProvider(cityId));
    final masjidAnnouncementsStream = ref.watch(activeAnnouncementsProvider(cityId));
    
    final isFollowing = ref.watch(isFollowingMasjidProvider(masjidId));

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ur' ? 'مسجد کی تفصیل' : 'Masjid Profile'),
      ),
      body: masjidsAsync.when(
        data: (masjids) {
          final idx = masjids.indexWhere((m) => m.id == masjidId);
          if (idx == -1) {
            return Center(child: Text(lang == 'ur' ? 'معلومات دستیاب نہیں ہیں' : 'Masjid not found.'));
          }
          final masjid = masjids[idx];

          return CustomScrollView(
            slivers: [
              // Header Card
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      lang == 'ur' || lang == 'ar' ? masjid.nameArabic : masjid.nameEnglish,
                                      style: GoogleFonts.cormorantGaramond(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.accentGold : AppColors.primaryEmerald,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (masjid.isVerified)
                                      const CustomPaint(
                                        size: Size(16, 16),
                                        painter: OctagonalSealPainter(color: AppColors.accentGold),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  masjid.address,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : AppColors.textDark,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Follow button
                          ElevatedButton(
                            onPressed: () {
                              ref.read(masjidFollowActionProvider).toggleFollow(masjid.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.grey.withOpacity(0.2) : AppColors.primaryEmerald,
                              foregroundColor: isFollowing ? (isDark ? Colors.white : Colors.black87) : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(
                              isFollowing ? getTranslation(lang, 'following') : getTranslation(lang, 'follow'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Follower Count
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            '${masjid.followerCount} ${lang == 'ur' ? 'برادری کے اراکین' : 'members following this masjid'}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Mock Location Map Box (Islamic style premium mockup)
                      Text(
                        lang == 'ur' ? 'مقام کا نقشه' : 'Location Map',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.backgroundDark : Colors.grey[150],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: MapMockupPainter(isDark: isDark),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryEmerald.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.navigation, size: 14, color: Colors.white),
                                      const SizedBox(width: 6),
                                      Text(
                                        lang == 'ur' ? 'نیویگیشن شروع کریں' : 'Open in Maps',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Upcoming programs title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
                  child: Text(
                    lang == 'ur' ? 'موجودہ پروگرامات' : 'Active Programs',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.accentGold : AppColors.primaryEmerald,
                    ),
                  ),
                ),
              ),
              
              // Upcoming programs feed list
              masjidAnnouncementsStream.when(
                data: (announcements) {
                  final masjidPrograms = announcements.where((a) => a.masjidId == masjid.id).toList();
                  
                  if (masjidPrograms.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          lang == 'ur' ? 'کوئی پروگرام نہیں ہے' : 'No scheduled programs for this masjid.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AnnouncementCard(announcement: masjidPrograms[index]);
                      },
                      childCount: masjidPrograms.length,
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

// Custom Painter for Map Mockup
class MapMockupPainter extends CustomPainter {
  final bool isDark;

  MapMockupPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black.withOpacity(0.08)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.grey[300]!
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke;

    // Draw main intersecting roads
    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.4)
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.55, size.height);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, linePaint);

    // Draw map location pin dot
    final pinPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.47, size.height * 0.37), 8, pinPaint);
    
    // Draw outer pulsing ring
    final ringPaint = Paint()
      ..color = AppColors.accentGold.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawCircle(Offset(size.width * 0.47, size.height * 0.37), 16, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
