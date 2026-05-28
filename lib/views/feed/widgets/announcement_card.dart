import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/colors.dart';
import '../../../models/announcement.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/preferences_provider.dart';
import '../../../services/location/prayer_times_calculator.dart';
import '../../../services/service_locator.dart';
import '../../../services/reminder_service.dart';
import '../../../utils/arabic_numbers.dart';
import '../../announcement/announcement_detail_sheet.dart';
import 'package:share_plus/share_plus.dart';

class AnnouncementCard extends ConsumerStatefulWidget {
  final Announcement announcement;

  const AnnouncementCard({
    super.key,
    required this.announcement,
  });

  @override
  ConsumerState<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends ConsumerState<AnnouncementCard> {
  Timer? _timer;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateTimeLeft();
      }
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    final difference = widget.announcement.scheduledTime.difference(now);
    
    // Countdown active if starting within 3 hours and is in the future
    if (difference.inMinutes > 0 && difference.inHours < 3) {
      setState(() {
        _timeLeft = difference;
      });
    } else {
      if (_timeLeft != null) {
        setState(() {
          _timeLeft = null;
        });
      }
    }
  }

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

  Future<void> _handleBookmark() async {
    final notifier = ref.read(preferencesProvider.notifier);
    await notifier.toggleSaveAnnouncement(widget.announcement.id);
    final prefs = ref.read(preferencesProvider);
    final isSaved = prefs.savedAnnouncements.contains(widget.announcement.id);
    final uid = prefs.anonymousUid;

    if (isSaved) {
      await savedService.saveAnnouncement(uid: uid, announcementId: widget.announcement.id);
    } else {
      await savedService.removeSavedAnnouncement(uid: uid, announcementId: widget.announcement.id);
    }
  }

  void _handleShare() {
    final lang = ref.read(localeProvider).languageCode;
    Share.share(
      'Join us for ${widget.announcement.title}\n'
      'Scholar: ${lang == 'ur' || lang == 'ar' ? widget.announcement.scholarNameArabicSnapshot : widget.announcement.scholarNameSnapshot}\n'
      'Masjid: ${widget.announcement.masjidNameSnapshot} (${widget.announcement.masjidLocalitySnapshot})\n'
      'Link: nidaapp.app/a/${widget.announcement.id}',
    );
  }

  void _handleReport() async {
    final lang = ref.read(localeProvider).languageCode;
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
      if (reason != null && mounted) {
        final prefs = ref.read(preferencesProvider);
        final uid = prefs.anonymousUid;
        await announcementsService.reportAnnouncement(widget.announcement.id, uid);
        if (mounted) {
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

  void _handleSetReminder() async {
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
          await ReminderService.cancelReminder(widget.announcement.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(lang == 'ur' ? 'یاد دہانی منسوخ کر دی گئی۔' : 'Reminder cancelled.')),
            );
          }
        } else {
          await ReminderService.scheduleReminder(
            announcement: widget.announcement,
            minutesBefore: minutes,
          );
          if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeState = ref.watch(localeProvider);
    final lang = localeState.languageCode;
    final prefsState = ref.watch(preferencesProvider);
    final isSaved = prefsState.savedAnnouncements.contains(widget.announcement.id);

    // Resolve prayer relative label
    // In our MockData, Kurnool city is used
    final cityId = widget.announcement.cityId;
    
    return FutureBuilder(
      future: citiesService.getCityById(cityId),
      builder: (context, snapshot) {
        final city = snapshot.data;
        final relativeTime = city != null
            ? PrayerTimesCalculator.getRelativePrayerLabel(city, widget.announcement.scheduledTime)
            : 'Today';

        final timeFormatted = '${widget.announcement.scheduledTime.hour.toString().padLeft(2, '0')}:${widget.announcement.scheduledTime.minute.toString().padLeft(2, '0')}';
        final displayTime = lang == 'ur' || lang == 'ar' ? toArabicDigits(timeFormatted) : timeFormatted;

        return Card(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AnnouncementDetailSheet(announcement: widget.announcement),
              );
            },
            child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Poster Left Area (Islamic Star Pattern Graphic)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryEmerald.withOpacity(0.85),
                          AppColors.primaryEmeraldLight,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background custom geometric painter or selected poster image
                        Positioned.fill(
                          child: widget.announcement.posterUrl != null
                              ? (widget.announcement.posterUrl!.startsWith('http')
                                  ? Image.network(widget.announcement.posterUrl!, fit: BoxFit.cover)
                                  : Image.file(File(widget.announcement.posterUrl!), fit: BoxFit.cover))
                              : CustomPaint(
                                  painter: GeometricStarPainter(
                                    color: AppColors.accentGold.withOpacity(0.2),
                                  ),
                                ),
                        ),
                        // Program Type badge on top left
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getProgramTypeColor(widget.announcement.programType),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.announcement.programType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 2. Info Right Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scholar Snapshot Row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lang == 'ur' || lang == 'ar'
                                    ? widget.announcement.scholarNameArabicSnapshot
                                    : widget.announcement.scholarNameSnapshot,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Card Options dropdown
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(maxWidth: 120),
                              onSelected: (value) {
                                if (value == 'report') _handleReport();
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flag_outlined, size: 16, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(lang == 'ur' ? 'رپورٹ کریں' : 'Report', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Masjid Snapshot Row
                        Row(
                          children: [
                            Text(
                              widget.announcement.masjidNameSnapshot,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            // Verified Masjid Badge
                            const CustomPaint(
                              size: Size(12, 12),
                              painter: OctagonalSealPainter(color: AppColors.accentGold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.announcement.masjidLocalitySnapshot})',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Program title
                        Text(
                          widget.announcement.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const Spacer(),
                        const SizedBox(height: 8),
                        
                        // Prayer times label & countdowns
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Adhan time representation
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '$relativeTime · $displayTime',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                            
                            // Countdown pill
                            if (_timeLeft != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                    .scale(end: const Offset(1.3, 1.3), duration: 800.ms),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${getTranslation(lang, 'startsIn')} ${formatMinutesToDuration(_timeLeft!.inMinutes, lang)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        const Divider(height: 16),
                        
                        // Action buttons row (Bookmark, Share)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: isSaved ? AppColors.accentGold : Colors.grey,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _handleBookmark,
                            ),
                            if (isSaved) ...[
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.notifications_active_outlined, color: AppColors.accentGold, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _handleSetReminder,
                              ),
                            ],
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _handleShare,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

// 8-Point Islamic Star Painter
class GeometricStarPainter extends CustomPainter {
  final Color color;

  GeometricStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw square 1
    final path1 = Path();
    path1.moveTo(center.dx - radius, center.dy - radius);
    path1.lineTo(center.dx + radius, center.dy - radius);
    path1.lineTo(center.dx + radius, center.dy + radius);
    path1.lineTo(center.dx - radius, center.dy + radius);
    path1.close();
    canvas.drawPath(path1, paint);

    // Draw square 2 (rotated 45 degrees)
    final path2 = Path();
    final d = radius * 1.414; // diagonal adjustment
    path2.moveTo(center.dx, center.dy - d);
    path2.lineTo(center.dx + d, center.dy);
    path2.lineTo(center.dx, center.dy + d);
    path2.lineTo(center.dx - d, center.dy);
    path2.close();
    canvas.drawPath(path2, paint);

    // Draw central circular motifs
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Octagonal Seal Painter for verified checkmark
class OctagonalSealPainter extends CustomPainter {
  final Color color;

  const OctagonalSealPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final path = Path();
    // 8 points of octagon
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw white checkmark inside
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    final checkPath = Path()
      ..moveTo(cx - r * 0.4, cy)
      ..lineTo(cx - r * 0.1, cy + r * 0.3)
      ..lineTo(cx + r * 0.4, cy - r * 0.3);
      
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
