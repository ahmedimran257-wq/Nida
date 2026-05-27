import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../widgets/islamic_pattern_background.dart';
import '../widgets/glassmorphic_container.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'region': 'Universal'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو', 'region': 'Nastaliq / South Asia'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية', 'region': 'Middle East / Global'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी', 'region': 'National'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు', 'region': 'Andhra / Telangana'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்', 'region': 'Tamil Nadu / Singapore'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം', 'region': 'Kerala / Gulf Diaspora'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা', 'region': 'West Bengal / Bangladesh'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslation(selectedLocale.languageCode, 'selectLanguage')),
        automaticallyImplyLeading: false,
      ),
      body: IslamicPatternBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                getTranslation(selectedLocale.languageCode, 'welcome'),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentGold : AppColors.primaryEmerald,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                getTranslation(selectedLocale.languageCode, 'tagline'),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = selectedLocale.languageCode == lang['code'];
                    
                    return InkWell(
                      onTap: () {
                        ref.read(localeProvider.notifier).setLanguage(lang['code']!);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: GlassmorphicContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16.0,
                        color: isSelected
                            ? (isDark 
                                ? AppColors.primaryEmerald.withOpacity(0.25) 
                                : AppColors.primaryEmerald.withOpacity(0.06))
                            : (isDark 
                                ? Colors.white.withOpacity(0.015) 
                                : Colors.white.withOpacity(0.55)),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentGold
                              : (isDark 
                                  ? Colors.white.withOpacity(0.06) 
                                  : Colors.black.withOpacity(0.06)),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              lang['native']!,
                              style: TextStyle(
                                fontSize: lang['code'] == 'ur' ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: lang['code'] == 'ur' ? 'Nastaliq' : null,
                                color: isSelected
                                    ? (isDark ? AppColors.accentGold : AppColors.primaryEmerald)
                                    : (isDark ? Colors.white : AppColors.textDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lang['name']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? (isDark ? Colors.white70 : AppColors.primaryEmeraldLight)
                                    : (isDark ? Colors.white60 : AppColors.textMutedDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang['region']!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.push('/location-permission');
                },
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
                    Text(
                      getTranslation(selectedLocale.languageCode, 'continueBtn'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      selectedLocale.textDirection == TextDirection.rtl
                          ? Icons.arrow_back // Points correctly in RTL
                          : Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
