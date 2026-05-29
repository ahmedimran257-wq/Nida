import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/preferences_provider.dart';
import '../widgets/islamic_pattern_background.dart';
import '../widgets/gold_foil_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for the animation to play
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs = ref.read(preferencesProvider);

    if (!prefs.isLanguageChosen) {
      context.go('/languages');
    } else if (prefs.cityId == null) {
      context.go('/location-permission');
    } else {
      context.go('/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primaryEmerald,
      body: IslamicPatternBackground(
        showStarsOnly: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Islamic Calligraphic Style Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGold, width: 2),
                color: Colors.white.withOpacity(0.05),
              ),
              child: const Icon(
                Icons.mosque_outlined,
                size: 64,
                color: AppColors.accentGold,
              ),
            )
            .animate()
            .fade(duration: 1000.ms)
            .scale(delay: 200.ms, duration: 800.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            // Bilingual App Header
            GoldFoilText(
              text: 'NIDA · نداء',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            )
            .animate()
            .fade(delay: 500.ms, duration: 800.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
            
            const SizedBox(height: 12),
            
            // Tagline
            Text(
              "Your community's call.",
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppColors.textMutedLight,
                letterSpacing: 0.5,
              ),
            )
            .animate()
            .fade(delay: 1000.ms, duration: 800.ms),
            
            const SizedBox(height: 64),
            
            // Premium Gold Shimmer Spinner
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                strokeWidth: 2.5,
              ),
            )
            .animate()
            .fade(delay: 1200.ms, duration: 500.ms),
          ],
        ),
      ),
      ),
    );
  }
}
