import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/admin_provider.dart';
import '../../services/mock/mock_data.dart';
import '../../services/service_locator.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  // Register Masjid controllers
  final _regNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regMasjidController = TextEditingController();
  final _regCityController = TextEditingController();

  bool _isSendingOtp = false;
  bool _otpSent = false;
  String? _loginError;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regMasjidController.dispose();
    _regCityController.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    final selectedLocale = ref.read(localeProvider);
    final lang = selectedLocale.languageCode;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(getTranslation(lang, 'selectLanguage')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _languageTile('en', 'English'),
                _languageTile('ur', 'اردو (Urdu)'),
                _languageTile('ar', 'العربية (Arabic)'),
                _languageTile('hi', 'हिंदी (Hindi)'),
                _languageTile('te', 'తెలుగు (Telugu)'),
                _languageTile('ta', 'தமிழ் (Tamil)'),
                _languageTile('ml', 'മലയാളം (Malayalam)'),
                _languageTile('bn', 'বাংলা (Bengali)'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageTile(String code, String name) {
    return ListTile(
      title: Text(name),
      onTap: () {
        ref.read(localeProvider.notifier).setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showMasjidRegisterDialog() {
    final lang = ref.read(localeProvider).languageCode;
    _regNameController.clear();
    _regPhoneController.clear();
    _regMasjidController.clear();
    _regCityController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            lang == 'ur' ? 'مسجد کی رجسٹریشن درخواست' : 'Register Your Masjid',
            style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _regNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: _regPhoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _regMasjidController,
                  decoration: const InputDecoration(labelText: 'Masjid Name'),
                ),
                TextField(
                  controller: _regCityController,
                  decoration: const InputDecoration(labelText: 'City / Country'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _regNameController.text.trim();
                final phone = _regPhoneController.text.trim();
                final masjid = _regMasjidController.text.trim();
                final city = _regCityController.text.trim();

                if (name.isEmpty || phone.isEmpty || masjid.isEmpty || city.isEmpty) return;

                Navigator.pop(context);

                await adminsService.submitAdminRequest(
                  name: name,
                  phone: phone,
                  masjidName: masjid,
                  cityName: city,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        lang == 'ur'
                            ? 'درخواست موصول ہو گئی! ہم جلد ہی تصدیق کے لیے رابطہ کریں گے۔'
                            : 'Request submitted successfully! We will call you within 24 hours to verify.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
              child: Text(lang == 'ur' ? 'جمع کریں' : 'Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showAdminLoginDialog() {
    _phoneController.clear();
    _otpController.clear();
    setState(() {
      _otpSent = false;
      _isSendingOtp = false;
      _loginError = null;
    });

    final lang = ref.read(localeProvider).languageCode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                _otpSent
                    ? (lang == 'ur' ? 'او ٹی پی درج کریں' : 'Enter OTP Verification')
                    : (lang == 'ur' ? 'ایڈمن لاگ ان' : 'Masjid Admin Login'),
                style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loginError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _loginError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                  if (!_otpSent) ...[
                    Text(
                      lang == 'ur'
                          ? 'اپنا موبائل نمبر درج کریں جو رجسٹرڈ ہے۔'
                          : 'Enter your registered phone number to receive a verification code.',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+91 99999 12345',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ] else ...[
                    Text(
                      lang == 'ur'
                          ? 'ہم نے تصدیقی کوڈ بھیجا ہے۔ (ٹیسٹ کوڈ: 123456)'
                          : 'We have sent a verification code to your phone. (Use code: 123456)',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otpController,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                        hintText: '123456',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                if (!_otpSent)
                  ElevatedButton(
                    onPressed: _isSendingOtp
                        ? null
                        : () async {
                            setDialogState(() => _isSendingOtp = true);
                            
                            // Simulate checking phone registration (Entry Point A check)
                            final phone = _phoneController.text.trim();
                            final hashed = MockData.hashPhone(phone);
                            final exists = MockData.imamAdmins.any((a) => a['phone'] == hashed && a['isActive'] == true);

                            await Future.delayed(const Duration(milliseconds: 600));

                            if (exists) {
                              setDialogState(() {
                                _isSendingOtp = false;
                                _otpSent = true;
                                _loginError = null;
                              });
                            } else {
                              setDialogState(() {
                                _isSendingOtp = false;
                                _loginError = 'Number not registered. Submit registration request first.';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
                    child: _isSendingOtp
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(lang == 'ur' ? 'او ٹی پی حاصل کریں' : 'Send OTP'),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (_otpController.text == '123456') {
                        final phone = _phoneController.text.trim();
                        final success = await ref.read(adminProvider.notifier).login(phone);
                        if (success && mounted) {
                          Navigator.pop(context);
                          context.push('/admin');
                        }
                      } else {
                        setDialogState(() {
                          _loginError = 'Invalid verification code. Try again.';
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
                    child: Text(lang == 'ur' ? 'تصدیق کریں' : 'Verify'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final lang = localeState.languageCode;
    final prefsState = ref.watch(preferencesProvider);
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslation(lang, 'settings')),
      ),
      body: ListView(
        children: [
          // 1. Language settings
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.accentGold),
            title: Text(getTranslation(lang, 'selectLanguage')),
            subtitle: Text(_languagesMap()[lang] ?? 'English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 1),
          
          // 2. Ramadan mode override toggle (for testing/demoing)
          SwitchListTile(
            secondary: const Icon(Icons.nightlight_round, color: AppColors.accentGold),
            title: Text(lang == 'ur' ? 'رمضان المبارک وضع (ڈیمو)' : 'Ramadan Mode (Demo Switch)'),
            subtitle: Text(lang == 'ur' ? 'پوری ایپ کو خوبصورت عنبر-گلابی رنگت میں منتقل کریں' : 'Shift app themes to amber-rose Ramadan mode styling'),
            value: prefsState.ramadanManualOverride,
            activeThumbColor: AppColors.accentGold,
            onChanged: (val) {
              ref.read(preferencesProvider.notifier).setRamadanOverride(val);
            },
          ),
          const Divider(height: 1),

          // 3. Register your Masjid form (Entry Point B)
          ListTile(
            leading: const Icon(Icons.app_registration, color: AppColors.accentGold),
            title: Text(getTranslation(lang, 'registerMasjid')),
            subtitle: Text(lang == 'ur' ? 'اپنے شہر میں نداء پر مسجد رجسٹر کریں' : 'Submit masjid coordinator requests for NIDA'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _showMasjidRegisterDialog,
          ),
          const Divider(height: 1),

          // 4. Admin section
          if (adminState.isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.dashboard_customize, color: Colors.green),
              title: Text(getTranslation(lang, 'adminPanel')),
              subtitle: Text('Logged in as: ${adminState.adminName}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/admin'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(getTranslation(lang, 'logout')),
              onTap: () {
                ref.read(adminProvider.notifier).logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out of Admin Portal.')),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.accentGold),
              title: Text(getTranslation(lang, 'imAnAdmin')),
              subtitle: Text(lang == 'ur' ? 'مساجد ایڈمنز کے لاگ ان کی جگہ' : 'Access posting and directory setup tools'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: _showAdminLoginDialog,
            ),
          ],
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: AppColors.accentGold),
            title: Text(lang == 'ur' ? 'سپر ایڈمن لاگ ان' : 'Super Admin Console'),
            subtitle: Text(lang == 'ur' ? 'پلیٹ فارم کے انتظام کے لیے' : 'Global platform controls and moderation'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => context.push('/superadmin'),
          ),
          const Divider(height: 1),
          
          // App Information Footer
          const SizedBox(height: 64),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
                context.push('/superadmin');
              },
              child: Column(
                children: [
                  Text(
                    'NIDA · نداء',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Version 5.0 (Super Admin Enabled)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const Text('Worldwide Location Seeding Active', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  const Text('(Double-tap logo to enter Super Admin Console)', style: TextStyle(color: Colors.white24, fontSize: 9)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _languagesMap() {
    return {
      'en': 'English',
      'ur': 'اردو (Urdu)',
      'ar': 'العربية (Arabic)',
      'hi': 'हिंदी (Hindi)',
      'te': 'తెలుగు (Telugu)',
      'ta': 'தமிழ் (Tamil)',
      'ml': 'മലയാളം (Malayalam)',
      'bn': 'বাংলা (Bengali)',
    };
  }
}
