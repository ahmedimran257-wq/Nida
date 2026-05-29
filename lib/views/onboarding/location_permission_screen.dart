import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/location/geocoding_stub.dart';
import '../../services/mock/mock_data.dart';
import '../widgets/islamic_pattern_background.dart';
import '../widgets/glassmorphic_container.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}


class _LocationPermissionScreenState extends ConsumerState<LocationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _handleAutoDetect() async {
    setState(() => _isLoading = true);

    // Simulate location permission request and coordinates delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Better mock: infer coordinates from device locale
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final countryCode = locale.countryCode ?? 'IN';
    final mockCity = MockData.cities.firstWhere(
      (c) => c['countryCode'] == countryCode && c['isActive'] == true,
      orElse: () => MockData.cities.firstWhere((c) => c['id'] == 'kurnool_in'),
    );
    final mockLat = mockCity['latitude'] as double? ?? 15.8281;
    final mockLon = mockCity['longitude'] as double? ?? 78.0373;

    final city = await GeocodingStub.detectCityFromCoordinates(mockLat, mockLon);

    setState(() => _isLoading = false);

    if (city != null) {
      if (city.isActive) {
        // City is active - save preference and proceed to notification permission request
        await ref.read(preferencesProvider.notifier).setCityId(city.id);
        await ref.read(preferencesProvider.notifier).setFirstLaunchComplete();
        if (mounted) {
          context.go('/notification-permission');
        }
      } else {
        // City is inactive - go to gate screen
        if (mounted) {
          context.go('/city-gate/${city.id}/${city.cityName}');
        }
      }
    } else {
      // Proximity search failed, fallback to manual city search
      if (mounted) {
        context.go('/city-search');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocale = ref.watch(localeProvider);
    final lang = selectedLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslation(lang, 'appName')),
      ),
      body: IslamicPatternBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Location Vector Icon
              Center(
                child: GlassmorphicContainer(
                  borderRadius: 60,
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.location_on_outlined,
                      size: 64,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                lang == 'ur' ? 'قریبی پروگرام تلاش کریں' : 'Find Local Programs',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentGold : AppColors.primaryEmerald,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                lang == 'ur'
                    ? 'نمازوں کے اوقات کے حساب اور آپ کی مسجد کے پروگراموں کی معلومات کے لیے لوکیشن کی ضرورت ہے۔'
                    : 'NIDA requires your location coordinates to determine local Islamic prayer calculation settings and discover bayans happening near you.',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                  ),
                )
              else ...[
                ElevatedButton(
                  onPressed: _handleAutoDetect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gps_fixed),
                      const SizedBox(width: 8),
                      Text(
                        getTranslation(lang, 'detectLocation'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    context.go('/city-search');
                  },
                  child: Text(
                    lang == 'ur' ? 'شہر دستی منتخب کریں' : 'Choose City Manually',
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
