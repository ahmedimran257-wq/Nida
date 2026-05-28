import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/location/prayer_times_calculator.dart';
import '../../services/service_locator.dart';
import '../../services/reminder_service.dart';
import '../../utils/arabic_numbers.dart';
import '../feed/widgets/announcement_card.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  final String announcementId;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  Color _getProgramTypeColor(String type) {
    switch (type) {
      case 'JANAZAH':
        return AppColors.error;
      case 'JUMUAH':
        return AppColors.primaryEmerald;
      case 'DARS':
        return AppColors.info;
      case 'SPECIAL':
        return AppColors.warning;
      case 'TARAWEEH':
      case 'QIYAAM':
      case 'IFTAR':
      case 'ITIKAF':
        return AppColors.ramadanRose;
      case 'BAYAN':
      default:
        return AppColors.accentGold;
    }
  }

  Future<void> _handleBookmark(WidgetRef ref, Announcement announcement) async {
    final notifier = ref.read(preferencesProvider.notifier);
    await notifier.toggleSaveAnnouncement(announcement.id);
    final prefs = ref.read(preferencesProvider);
    final isSaved = prefs.savedAnnouncements.contains(announcement.id);
    final uid = prefs.anonymousUid;

    if (isSaved) {
      await savedService.saveAnnouncement(uid: uid, announcementId: announcement.id);
    } else {
      await savedService.removeSavedAnnouncement(uid: uid, announcementId: announcement.id);
    }
  }

  void _handleShare(String lang, Announcement announcement) {
    Share.share(
      'Join us for ${announcement.title}\n'
      'Scholar: ${lang == 'ur' || lang == 'ar' ? announcement.scholarNameArabicSnapshot : announcement.scholarNameSnapshot}\n'
      'Masjid: ${announcement.masjidNameSnapshot} (${announcement.masjidLocalitySnapshot})\n'
      'Link: nidaapp.app/a/${announcement.id}',
    );
  }

  void _handleReport(BuildContext context, String lang, WidgetRef ref, Announcement announcement) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          title: Text(lang == 'ur' ? 'رپورٹ کریں' : 'Report Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(lang == 'ur' ? 'غلط معلومات' : 'Incorrect Information'),
                onTap: () => Navigator.pop(context, 'wrong'),
              ),
              ListTile(
                title: Text(lang == 'ur' ? 'سپیم / اشتہار' : 'Spam / Advertisement'),
                onTap: () => Navigator.pop(context, 'spam'),
              ),
              ListTile(
                title: Text(lang == 'ur' ? 'نا مناسب مواد' : 'Offensive Content'),
                onTap: () => Navigator.pop(context, 'offensive'),
              ),
            ],
          ),
        );
      },
    ).then((reason) async {
      if (reason != null) {
        final prefs = ref.read(preferencesProvider);
        final uid = prefs.anonymousUid;
        await announcementsService.reportAnnouncement(announcement.id, uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'ur' ? 'شکریہ، آپ کی رپورٹ موصول ہو گئی۔' : 'Report submitted. Thank you for keeping NIDA safe.',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    });
  }

  void _handleSetReminder(BuildContext context, WidgetRef ref, Announcement announcement) async {
    final lang = ref.read(localeProvider).languageCode;
    
    showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          title: Text(lang == 'ur' ? 'یاد دہانی ترتیب دیں' : 'Set Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.alarm, color: AppColors.accentGold),
                title: Text(lang == 'ur' ? '15 منٹ پہلے' : '15 minutes before'),
                onTap: () => Navigator.pop(context, 15),
              ),
              ListTile(
                leading: const Icon(Icons.alarm, color: AppColors.accentGold),
                title: Text(lang == 'ur' ? '30 منٹ پہلے' : '30 minutes before'),
                onTap: () => Navigator.pop(context, 30),
              ),
              ListTile(
                leading: const Icon(Icons.alarm, color: AppColors.accentGold),
                title: Text(lang == 'ur' ? '1 گھنٹہ پہلے' : '1 hour before'),
                onTap: () => Navigator.pop(context, 60),
              ),
              ListTile(
                leading: const Icon(Icons.alarm, color: AppColors.accentGold),
                title: Text(lang == 'ur' ? '1 دن پہلے' : '1 day before'),
                onTap: () => Navigator.pop(context, 1440),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications_off, color: Colors.grey),
                title: Text(lang == 'ur' ? 'منسوخ کریں' : 'Cancel Reminder'),
                onTap: () => Navigator.pop(context, -1),
              ),
            ],
          ),
        );
      },
    ).then((minutes) async {
      if (minutes != null) {
        if (minutes == -1) {
          await ReminderService.cancelReminder(announcement.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(lang == 'ur' ? 'یاد دہانی منسوخ کر دی گئی۔' : 'Reminder cancelled.')),
            );
          }
        } else {
          await ReminderService.scheduleReminder(
            announcement: announcement,
            minutesBefore: minutes,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  lang == 'ur'
                      ? 'یاد دہانی $minutes منٹ پہلے کے لیے ترتیب دی گئی ہے۔'
                      : 'Reminder scheduled $minutes minutes before the program.',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    });
  }

  Future<Announcement?> _fetchAnnouncement() {
    return announcementsService.getAnnouncementById(announcementId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeState = ref.watch(localeProvider);
    final lang = localeState.languageCode;
    final prefsState = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ur' ? 'تفصیلات' : 'Announcement Detail'),
      ),
      body: FutureBuilder<Announcement?>(
        future: _fetchAnnouncement(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final announcement = snapshot.data;
          if (announcement == null) {
            return Center(
              child: Text(lang == 'ur' ? 'پروگرام نہیں ملا' : 'Announcement not found.'),
            );
          }

          final isSaved = prefsState.savedAnnouncements.contains(announcement.id);
          final cityId = announcement.cityId;

          return FutureBuilder(
            future: citiesService.getCityById(cityId),
            builder: (context, citySnapshot) {
              final city = citySnapshot.data;
              final relativeTime = city != null
                  ? PrayerTimesCalculator.getRelativePrayerLabel(city, announcement.scheduledTime)
                  : 'Today';

              final timeFormatted = '${announcement.scheduledTime.hour.toString().padLeft(2, '0')}:${announcement.scheduledTime.minute.toString().padLeft(2, '0')}';
              final displayTime = lang == 'ur' || lang == 'ar' ? toArabicDigits(timeFormatted) : timeFormatted;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Geometric Star Card Header
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryEmerald.withOpacity(0.9),
                                AppColors.primaryEmeraldLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: GeometricStarPainter(
                                    color: AppColors.accentGold.withOpacity(0.18),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getProgramTypeColor(announcement.programType),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    announcement.programType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  announcement.programType,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Scholar Details
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            lang == 'ur' || lang == 'ar'
                                ? announcement.scholarNameArabicSnapshot
                                : announcement.scholarNameSnapshot,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                          subtitle: Text(
                            lang == 'ur' ? 'عالم دین' : 'Speaker / Scholar',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        const Divider(),

                        // Masjid Details
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Text(
                                announcement.masjidNameSnapshot,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              const CustomPaint(
                                size: Size(14, 14),
                                painter: OctagonalSealPainter(color: AppColors.accentGold),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            announcement.masjidLocalitySnapshot,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          trailing: const Icon(Icons.location_on_outlined, color: AppColors.accentGold),
                          onTap: () {
                            context.push('/masjid/${announcement.masjidId}');
                          },
                        ),
                        const Divider(),

                        // Timing details
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$relativeTime · $displayTime',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  lang == 'ur' ? 'پروگرام کا وقت' : 'Scheduled Timing',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),

                        // Description details
                        const SizedBox(height: 12),
                        Text(
                          lang == 'ur' ? 'تفصیلات' : 'PROGRAM DETAILS',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (announcement.description ?? '').isNotEmpty
                              ? announcement.description!
                              : (lang == 'ur' ? 'تفصیلات دستیاب نہیں ہیں۔' : 'No description provided.'),
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  // Bottom buttons bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                           Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _handleBookmark(ref, announcement),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSaved
                                    ? Colors.grey.withOpacity(0.2)
                                    : AppColors.primaryEmerald,
                                foregroundColor: isSaved
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                              label: Text(
                                isSaved
                                    ? (lang == 'ur' ? 'محفوظ شدہ' : 'Saved')
                                    : (lang == 'ur' ? 'محفوظ کریں' : 'Save'),
                              ),
                            ),
                          ),
                          if (isSaved) ...[
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () => _handleSetReminder(context, ref, announcement),
                              icon: const Icon(Icons.notifications_active_outlined, color: AppColors.accentGold),
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                                ),
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _handleShare(lang, announcement),
                            icon: const Icon(Icons.share_outlined),
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _handleReport(context, lang, ref, announcement),
                            icon: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
