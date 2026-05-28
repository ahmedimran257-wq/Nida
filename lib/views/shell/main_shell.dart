import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/locale_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _routes = ['/feed', '/directory', '/saved'];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/directory')) return 1;
    if (location.startsWith('/saved')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.accentGold.withOpacity(0.18),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            context.go(_routes[index]);
          },
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primaryEmerald,
          selectedItemColor: AppColors.accentGold,
          unselectedItemColor: isDark ? Colors.white38 : Colors.white60,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.mosque_outlined),
              label: lang == 'ur' ? 'ہوم' : 'Feed',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              label: lang == 'ur' ? 'ڈائریکٹری' : 'Explore',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark_outline),
              label: lang == 'ur' ? 'محفوظ' : 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}
