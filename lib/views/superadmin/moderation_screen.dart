import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../providers/superadmin_provider.dart';
import '../../services/mock/mock_data.dart';
import '../../services/service_locator.dart';

class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(superAdminProvider);

    // Fetch hidden announcements directly from MockData for super admin moderation purposes
    final hiddenAnnouncements = MockData.announcements
        .where((a) => a['isHidden'] == true)
        .map((a) => Announcement.fromMockMap(a))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: Text(
            'Content Moderation',
            style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Flagged / Reported'),
              Tab(text: 'Hidden Archive'),
            ],
            indicatorColor: AppColors.accentGold,
            labelColor: AppColors.accentGold,
            unselectedLabelColor: Colors.white60,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Flagged/Reported
            state.flaggedAnnouncements.isEmpty
                ? const Center(
                    child: Text('No announcements currently flagged.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: state.flaggedAnnouncements.length,
                    itemBuilder: (context, index) {
                      final a = state.flaggedAnnouncements[index];
                      return Card(
                        color: AppColors.surfaceDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Reports: ${a.reportCount}',
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'By Admin ID: ${a.postedBy}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                a.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                a.description ?? 'No description.',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Masjid: ${a.masjidNameSnapshot} (${a.masjidLocalitySnapshot})',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const Divider(height: 24, color: Colors.white10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      ref.read(superAdminProvider.notifier).dismissFlaggedAnnouncement(a.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Reports dismissed.')),
                                      );
                                    },
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Dismiss Reports'),
                                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ref.read(superAdminProvider.notifier).hideAnnouncement(a.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Announcement permanently hidden.')),
                                      );
                                    },
                                    icon: const Icon(Icons.block, size: 16),
                                    label: const Text('Hide Globally'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // Tab 2: Hidden Archive
            hiddenAnnouncements.isEmpty
                ? const Center(
                    child: Text('No announcements in hidden archive.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: hiddenAnnouncements.length,
                    itemBuilder: (context, index) {
                      final a = hiddenAnnouncements[index];
                      return Card(
                        color: AppColors.surfaceDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white10),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(a.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Masjid: ${a.masjidNameSnapshot} · Hidden By Super Admin',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              final idx = MockData.announcements.indexWhere((x) => x['id'] == a.id);
                              if (idx != -1) {
                                MockData.announcements[idx]['isHidden'] = false;
                                adminsService.addAuditLog(
                                  action: 'Moderation: Reinstated announcement "${a.title}"',
                                  performedBy: 'superAdmin',
                                );
                                ref.read(superAdminProvider.notifier).loadData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Announcement reinstated.'), backgroundColor: AppColors.success),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryEmerald,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Reinstate'),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
