import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/superadmin_provider.dart';

class SuperAdminDashboard extends ConsumerStatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  ConsumerState<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<SuperAdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(superAdminProvider.notifier).loadData();
    });
  }

  Widget _statsCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentGold.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
                Icon(icon, color: AppColors.accentGold, size: 14),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.accentGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(superAdminProvider);

    if (!state.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              const Text('Restricted Access', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/superadmin'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final activeCitiesCount = state.cities.where((c) => c['isActive'] == true).length;
    final totalRequests = state.pendingRequests.length;
    final totalFlagged = state.flaggedAnnouncements.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
        title: Text(
          'Super Admin Console',
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
            color: AppColors.accentGold,
          ),
        ),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              ref.read(superAdminProvider.notifier).logout();
              context.go('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(superAdminProvider.notifier).loadData(),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Stats Row
            Row(
              children: [
                _statsCard('Active Cities', activeCitiesCount.toString(), Icons.location_city),
                const SizedBox(width: 8),
                _statsCard('Pending Requests', totalRequests.toString(), Icons.app_registration),
                const SizedBox(width: 8),
                _statsCard('Flagged Posts', totalFlagged.toString(), Icons.flag_outlined),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Menu Controls
            const Text(
              'PLATFORM CONTROLS',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/superadmin/cities'),
                    icon: const Icon(Icons.location_city),
                    label: const Text('Manage Cities'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      foregroundColor: AppColors.accentGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: AppColors.accentGold.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/superadmin/moderation'),
                    icon: const Icon(Icons.security),
                    label: const Text('Moderation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      foregroundColor: AppColors.accentGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: AppColors.accentGold.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/superadmin/audit-logs'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Action Audit Logs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceDark,
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.white10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 32),

            // Pending requests header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PENDING COORDINATOR REQUESTS ($totalRequests)',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                if (totalRequests > 0)
                  const Text('Tap to review', style: TextStyle(color: AppColors.accentGold, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),

            if (state.pendingRequests.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No pending registration requests.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.pendingRequests.length,
                itemBuilder: (context, index) {
                  final req = state.pendingRequests[index];
                  return Card(
                    color: AppColors.surfaceDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(req['masjidName'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Requested by ${req['name']} · ${req['cityName']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.accentGold),
                      onTap: () => context.push('/superadmin/requests/${req['id']}'),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),

            // Flagged announcements header
            Text(
              'REPORTED ANNOUNCEMENTS ($totalFlagged)',
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (state.flaggedAnnouncements.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No reported or flagged content.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.flaggedAnnouncements.length,
                itemBuilder: (context, index) {
                  final a = state.flaggedAnnouncements[index];
                  return Card(
                    color: AppColors.surfaceDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.error.withOpacity(0.2)),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(a.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Posted at ${a.masjidNameSnapshot} · Reports: ${a.reportCount}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            onPressed: () => ref
                                .read(superAdminProvider.notifier)
                                .dismissFlaggedAnnouncement(a.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.block, color: Colors.red),
                            onPressed: () => ref
                                .read(superAdminProvider.notifier)
                                .hideAnnouncement(a.id),
                          ),
                        ],
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
