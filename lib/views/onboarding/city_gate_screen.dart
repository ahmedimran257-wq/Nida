import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/service_locator.dart';

class CityGateScreen extends ConsumerStatefulWidget {
  final String cityId;
  final String cityName;

  const CityGateScreen({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  ConsumerState<CityGateScreen> createState() => _CityGateScreenState();
}

class _CityGateScreenState extends ConsumerState<CityGateScreen> {
  bool _isSubmitted = false;
  bool _isLoading = false;

  Future<void> _handleWaitlistJoin() async {
    setState(() => _isLoading = true);

    final prefs = ref.read(preferencesProvider);
    final mockToken = 'fcm_token_${prefs.anonymousUid}';

    await citiesService.joinWaitlist(cityId: widget.cityId, fcmToken: mockToken);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Custom Painted Mosque Illustration
              Center(
                child: SizedBox(
                  width: 160,
                  height: 120,
                  child: CustomPaint(
                    painter: MosquePainter(
                      color: isDark ? AppColors.accentGold : AppColors.primaryEmerald,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                lang == 'ur'
                    ? 'نداء آرہا ہے ${widget.cityName} میں'
                    : 'NIDA is coming to ${widget.cityName}',
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
                    ? 'ہم شہر بہ شہر آگے بڑھ رہے ہیں۔ سب سے پہلے جاننے کے لیے کہ کب ہم آپ کے شہر میں لائیو ہوتے ہیں، نیچے کلک کریں۔'
                    : "We're growing city by city. Be the first to know the moment NIDA launches in ${widget.cityName} to discover local programs.",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              if (_isSubmitted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        lang == 'ur'
                            ? 'کام ہو گیا! شہر لائیو ہوتے ہی آپ کو مطلع کر دیا جائے گا۔'
                            : "Done! We'll notify you the moment NIDA launches in ${widget.cityName}.",
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _handleWaitlistJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    getTranslation(lang, 'notifyMe'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(
                  lang == 'ur' ? 'دوسرا شہر تلاش کریں' : 'Browse Another City',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Vector Mosque Painter
class MosquePainter extends CustomPainter {
  final Color color;

  MosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    // Draw base line
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    // Left minaret
    path.moveTo(size.width * 0.1, size.height);
    path.lineTo(size.width * 0.1, size.height * 0.3);
    path.lineTo(size.width * 0.15, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.2, size.height);

    // Right minaret
    path.moveTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width * 0.85, size.height * 0.2);
    path.lineTo(size.width * 0.9, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height);

    // Central Dome structure
    path.moveTo(size.width * 0.3, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    
    // Dome curve
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.5,
    );
    path.lineTo(size.width * 0.7, size.height);

    // Dome crescent rod
    path.moveTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.5, size.height * 0.05);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
