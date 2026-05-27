import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/colors.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/feed_provider.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  static const List<Map<String, String>> _categories = [
    {'key': 'ALL', 'labelEn': 'All', 'labelUr': 'تمام'},
    {'key': 'BAYAN', 'labelEn': 'Bayan', 'labelUr': 'بیان'},
    {'key': 'DARS', 'labelEn': 'Dars', 'labelUr': 'درس'},
    {'key': 'JUMUAH', 'labelEn': 'Jumu\'ah', 'labelUr': 'جمعہ'},
    {'key': 'SPECIAL', 'labelEn': 'Special', 'labelUr': 'خصوصی'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(feedCategoryFilterProvider);
    final lang = ref.watch(localeProvider).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = activeCategory == cat['key'];
          final label = lang == 'ur' ? cat['labelUr']! : cat['labelEn']!;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(feedCategoryFilterProvider.notifier).state = cat['key']!;
              },
              selectedColor: AppColors.primaryEmerald,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.textDark),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.white24 : Colors.black12),
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }
}
