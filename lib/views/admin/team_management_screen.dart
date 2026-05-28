import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/admin_provider.dart';
import '../../services/service_locator.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  ConsumerState<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  final _inviteNameController = TextEditingController();
  final _invitePhoneController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _team = [];

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    setState(() => _isLoading = true);
    final adminState = ref.read(adminProvider);
    final cityId = adminState.cityId ?? 'kurnool_in';
    final list = await adminsService.getAdminsByCity(cityId);
    if (mounted) {
      setState(() {
        _team = list;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _inviteNameController.dispose();
    _invitePhoneController.dispose();
    super.dispose();
  }

  void _showInviteDialog(String cityId) {
    _inviteNameController.clear();
    _invitePhoneController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Invite Co-Admin',
            style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _inviteNameController,
                decoration: const InputDecoration(labelText: 'Admin Name'),
              ),
              TextField(
                controller: _invitePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91 99999 00000',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _inviteNameController.text.trim();
                final phone = _invitePhoneController.text.trim();
                
                if (name.isEmpty || phone.isEmpty) return;

                Navigator.pop(context);
                setState(() => _isLoading = true);

                final err = await ref.read(adminProvider.notifier).inviteAdmin(name, phone);
                
                if (mounted) {
                  setState(() => _isLoading = false);
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.error));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invitation sent. Share the NIDA app link with them to verify!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    _loadTeam(); // Reload team
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeactivate(String adminId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deactivate Coordinator?'),
          content: Text('Are you sure you want to deactivate $name? This frees up a slot in your city admin limit.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                
                final err = await ref.read(adminProvider.notifier).softDeactivateAdmin(adminId);
                
                if (mounted) {
                  setState(() => _isLoading = false);
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.error));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coordinator deactivated successfully.'), backgroundColor: AppColors.success),
                    );
                    _loadTeam(); // Reload team
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final cityId = adminState.cityId ?? 'kurnool_in';

    // Query active coordinators for this city using loaded team list
    final team = _team;
    final activeCount = team.where((a) => a['isActive'] == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Team')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Slot stats header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: isDark ? AppColors.surfaceDark : AppColors.primaryEmerald.withOpacity(0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('City Limit Slots', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '$activeCount / 10 Active Admins',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showInviteDialog(cityId),
                        icon: const Icon(Icons.add),
                        label: const Text('Invite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryEmerald,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // List of members
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: team.length,
                    itemBuilder: (context, index) {
                      final member = team[index];
                      final isCurrent = member['id'] == adminState.adminId;
                      final isActive = member['isActive'] as bool;

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
                              Text(member['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('YOU', style: TextStyle(fontSize: 8, color: Colors.black87, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text('Phone: ${member['phoneDisplay']} · Posts: ${member['announcementsPosted']}'),
                              const SizedBox(height: 4),
                              Text(
                                isActive ? 'Active Coordinator' : 'Deactivated',
                                style: TextStyle(
                                  color: isActive ? Colors.green : Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: (isCurrent || !isActive)
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                  onPressed: () => _confirmDeactivate(member['id'] as String, member['name'] as String),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
