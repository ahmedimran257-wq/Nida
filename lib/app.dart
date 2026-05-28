import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/colors.dart';
import 'providers/locale_provider.dart';
import 'providers/preferences_provider.dart';

// Screens
import 'models/announcement.dart';
import 'views/onboarding/splash_screen.dart';
import 'views/onboarding/language_selection_screen.dart';
import 'views/onboarding/location_permission_screen.dart';
import 'views/onboarding/city_search_screen.dart';
import 'views/onboarding/city_gate_screen.dart';
import 'views/feed/feed_screen.dart';
import 'views/directory/directory_tabs_screen.dart';
import 'views/directory/scholar_detail_screen.dart';
import 'views/directory/masjid_detail_screen.dart';
import 'views/saved/saved_screen.dart';
import 'views/settings/settings_screen.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/admin/post_announcement_screen.dart';
import 'views/admin/add_scholar_screen.dart';
import 'views/admin/add_masjid_screen.dart';
import 'views/admin/team_management_screen.dart';
import 'views/shell/main_shell.dart';
import 'views/announcement/announcement_detail_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/languages', builder: (context, state) => const LanguageSelectionScreen()),
      GoRoute(path: '/location-permission', builder: (context, state) => const LocationPermissionScreen()),
      GoRoute(path: '/city-search', builder: (context, state) => const CitySearchScreen()),
      GoRoute(
        path: '/city-gate/:cityId/:cityName',
        builder: (context, state) {
          final cityId = state.pathParameters['cityId']!;
          final cityName = state.pathParameters['cityName']!;
          return CityGateScreen(cityId: cityId, cityName: cityName);
        },
      ),
      
      // Bottom Navigation Shell Route
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (context, state) => const FeedScreen()),
          GoRoute(path: '/directory', builder: (context, state) => const DirectoryTabsScreen()),
          GoRoute(path: '/saved', builder: (context, state) => const SavedScreen()),
        ],
      ),

      GoRoute(
        path: '/scholar/:id',
        builder: (context, state) => ScholarDetailScreen(scholarId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/masjid/:id',
        builder: (context, state) => MasjidDetailScreen(masjidId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/announcement/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AnnouncementDetailScreen(announcementId: id);
        },
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      
      // Admin Portal Routes
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboard()),
      GoRoute(
        path: '/admin/post',
        builder: (context, state) {
          final announcement = state.extra as Announcement?;
          return PostAnnouncementScreen(announcement: announcement);
        },
      ),
      GoRoute(path: '/admin/add-scholar', builder: (context, state) => const AddScholarScreen()),
      GoRoute(path: '/admin/add-masjid', builder: (context, state) => const AddMasjidScreen()),
      GoRoute(path: '/admin/team', builder: (context, state) => const TeamManagementScreen()),
    ],
  );
});

class NidaApp extends ConsumerWidget {
  const NidaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final localeState = ref.watch(localeProvider);
    final prefsState = ref.watch(preferencesProvider);

    final isRamadan = prefsState.ramadanManualOverride;

    // Misbah Theme Configuration
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: isRamadan ? AppColors.ramadanAmber : AppColors.primaryEmerald,
        primary: isRamadan ? AppColors.ramadanAmber : AppColors.primaryEmerald,
        secondary: AppColors.accentGold,
        error: AppColors.error,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        titleLarge: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.bold,
          color: isRamadan ? AppColors.ramadanRose : AppColors.primaryEmerald,
        ),
        titleMedium: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w600,
          color: isRamadan ? AppColors.ramadanRose : AppColors.primaryEmerald,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isRamadan ? AppColors.ramadanBgDark : AppColors.primaryEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    final baseDarkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: isRamadan ? AppColors.ramadanAmber : AppColors.primaryEmerald,
        primary: isRamadan ? AppColors.ramadanAmber : AppColors.primaryEmerald,
        secondary: AppColors.accentGold,
        error: AppColors.error,
        brightness: Brightness.dark,
        background: isRamadan ? AppColors.ramadanBgDark : AppColors.backgroundDark,
        surface: isRamadan ? AppColors.ramadanSurfaceDark : AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: isRamadan ? AppColors.ramadanBgDark : AppColors.backgroundDark,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.bold,
          color: AppColors.accentGold,
        ),
        titleMedium: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w600,
          color: AppColors.accentGold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isRamadan ? AppColors.ramadanSurfaceDark : AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.accentGold,
        ),
      ),
    );

    return MaterialApp.router(
      title: 'NIDA',
      theme: baseTheme,
      darkTheme: baseDarkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: Locale(localeState.languageCode),
      supportedLocales: const [
        Locale('en', ''),
        Locale('ur', ''),
        Locale('te', ''),
        Locale('hi', ''),
        Locale('ar', ''),
        Locale('ta', ''),
        Locale('ml', ''),
        Locale('bn', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Enforces RTL text direction based on the current locale
        return Directionality(
          textDirection: localeState.textDirection,
          child: child!,
        );
      },
    );
  }
}
