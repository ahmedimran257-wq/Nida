import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/superadmin_provider.dart';

class AdminRequestDetailScreen extends ConsumerWidget {
  final String requestId;

  const AdminRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(superAdminProvider);
    final req = state.pendingRequests.firstWhere(
      (r) => r['id'] == requestId,
      orElse: () => <String, dynamic>{},
    );

    if (req.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(title: const Text('Request Details')),
        body: const Center(
          child: Text('Request not found.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Review Request',
          style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Icon header card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.app_registration, color: AppColors.accentGold, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          req['masjidName'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          req['cityName'] as String,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Request Information
                  const Text('REQUEST DETAILS', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  _infoTile('Coordinator Name', req['name'] as String),
                  _infoTile('Phone Number', req['phone'] as String),
                  _infoTile('Masjid Name', req['masjidName'] as String),
                  _infoTile('Target City ID', req['cityId'] as String),
                  _infoTile('Status', (req['status'] as String).toUpperCase(), valueColor: Colors.amber),
                  
                  const SizedBox(height: 16),
                  const Text('COORDINATOR NOTE', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (req['note'] as String).isNotEmpty ? req['note'] as String : 'No note provided by the coordinator.',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // Approve & Reject Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(superAdminProvider.notifier).rejectAdminRequest(requestId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request rejected.')),
                        );
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject Request', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(superAdminProvider.notifier).approveAdminRequest(requestId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request approved! Admin is active and city is launched.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Approve Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
