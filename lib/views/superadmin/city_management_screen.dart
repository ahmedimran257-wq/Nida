import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/superadmin_provider.dart';

class CityManagementScreen extends ConsumerWidget {
  const CityManagementScreen({super.key});

  int _getMockWaitlistCount(String cityId) {
    switch (cityId) {
      case 'hyderabad_in':
        return 47;
      case 'mumbai_in':
        return 162;
      case 'london_gb':
        return 124;
      case 'chicago_us':
        return 89;
      case 'sydney_au':
        return 38;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(superAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Manage Cities',
          style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: state.cities.length,
        itemBuilder: (context, index) {
          final city = state.cities[index];
          final cityId = city['id'] as String;
          final isActive = city['isActive'] as bool;
          final adminCount = city['adminCount'] as int;
          final waitlistCount = _getMockWaitlistCount(cityId);

          return Card(
            color: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? AppColors.primaryEmerald.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${city['cityName']}, ${city['country']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Timezone: ${city['timezone']} · Method: ${city['calculationMethod']}',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                      Switch(
                        value: isActive,
                        activeColor: AppColors.primaryEmerald,
                        onChanged: (val) {
                          ref.read(superAdminProvider.notifier).toggleCityActivation(cityId, val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                val
                                    ? 'Activated ${city['cityName']}! Notified $waitlistCount waitlisted users.'
                                    : 'Deactivated ${city['cityName']}.',
                              ),
                              backgroundColor: val ? AppColors.success : Colors.black87,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline, color: AppColors.accentGold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '$adminCount / ${city['maxAdmins']} Admins',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.mark_chat_unread_outlined, color: AppColors.accentGold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? '0 Waiting (Launched)' : '$waitlistCount Waiting in Waitlist',
                            style: TextStyle(
                              color: isActive ? Colors.grey : AppColors.accentGold,
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
