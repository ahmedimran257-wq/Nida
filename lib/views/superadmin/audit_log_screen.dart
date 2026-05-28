import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../providers/superadmin_provider.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(superAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Action Audit Logs',
          style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
      ),
      body: state.auditLogs.isEmpty
          ? const Center(
              child: Text('No audit logs available.', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: state.auditLogs.length,
              itemBuilder: (context, index) {
                final log = state.auditLogs[index];
                final timestamp = log['timestamp'] as DateTime;
                final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

                return Card(
                  color: AppColors.surfaceDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.white.withOpacity(0.04)),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history_outlined, color: AppColors.accentGold, size: 22),
                    title: Text(
                      log['action'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    subtitle: Text(
                      'By: ${log['performedBy']} · $formattedTime',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
