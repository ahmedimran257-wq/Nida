import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/announcement.dart';
import '../services/service_locator.dart';
import 'preferences_provider.dart';

// Stream of active announcements for the selected city
final activeAnnouncementsProvider = StreamProvider.family<List<Announcement>, String>((ref, cityId) {
  return announcementsService.watchActiveAnnouncements(cityId);
});

// Category filter chip state (ALL, BAYAN, DARS, JUMUAH, SPECIAL, etc.)
final feedCategoryFilterProvider = StateProvider<String>((ref) => 'ALL');

// Search query state
final feedSearchQueryProvider = StateProvider<String>((ref) => '');

// Tab selection state: 0 = For You, 1 = All
final feedTabSelectionProvider = StateProvider<int>((ref) => 1); // Defaults to All

// Filtered announcements provider combining active, tab selection, followed masjids, categories, and search
final filteredAnnouncementsProvider = Provider.family<AsyncValue<List<Announcement>>, String>((ref, cityId) {
  final activeAsync = ref.watch(activeAnnouncementsProvider(cityId));
  final selectedTab = ref.watch(feedTabSelectionProvider);
  final prefs = ref.watch(preferencesProvider);
  final categoryFilter = ref.watch(feedCategoryFilterProvider);
  final searchQuery = ref.watch(feedSearchQueryProvider).toLowerCase().trim();

  return activeAsync.whenData((list) {
    List<Announcement> filtered = List.from(list);

    // 1. Filter by Tab (For You vs All)
    if (selectedTab == 0 && prefs.followedMasjids.isNotEmpty) {
      filtered = filtered.where((a) => prefs.followedMasjids.contains(a.masjidId)).toList();
    }

    // 2. Filter by Category Chip
    if (categoryFilter != 'ALL') {
      filtered = filtered.where((a) => a.programType == categoryFilter).toList();
    }

    // 3. Filter by Search Query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((a) =>
          a.title.toLowerCase().contains(searchQuery) ||
          (a.description?.toLowerCase().contains(searchQuery) ?? false) ||
          a.scholarNameSnapshot.toLowerCase().contains(searchQuery) ||
          a.masjidNameSnapshot.toLowerCase().contains(searchQuery) ||
          a.masjidLocalitySnapshot.toLowerCase().contains(searchQuery)).toList();
    }

    // Sort by soonest scheduled time first
    filtered.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return filtered;
  });
});

// Selector for currently live announcements (Live Now)
final liveAnnouncementsProvider = Provider.family<AsyncValue<List<Announcement>>, String>((ref, cityId) {
  final activeAsync = ref.watch(activeAnnouncementsProvider(cityId));

  return activeAsync.whenData((list) {
    final now = DateTime.now();
    return list.where((a) {
      // Live if scheduledTime is in past but not yet expired
      return now.isAfter(a.scheduledTime) && now.isBefore(a.expiresAt);
    }).toList();
  });
});

// Grouped announcements model
class GroupedFeed {
  final List<Announcement> today;
  final List<Announcement> tomorrow;
  final List<Announcement> thisWeek;
  final List<Announcement> comingUp;

  GroupedFeed({
    required this.today,
    required this.tomorrow,
    required this.thisWeek,
    required this.comingUp,
  });

  bool get isEmpty => today.isEmpty && tomorrow.isEmpty && thisWeek.isEmpty && comingUp.isEmpty;
}

// Provider to group filtered announcements by day
final groupedFeedProvider = Provider.family<AsyncValue<GroupedFeed>, String>((ref, cityId) {
  final filteredAsync = ref.watch(filteredAnnouncementsProvider(cityId));

  return filteredAsync.whenData((list) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final tomorrowEnd = todayEnd.add(const Duration(days: 1));
    final weekEnd = todayEnd.add(const Duration(days: 7));

    final List<Announcement> today = [];
    final List<Announcement> tomorrow = [];
    final List<Announcement> thisWeek = [];
    final List<Announcement> comingUp = [];

    final liveNow = ref.read(liveAnnouncementsProvider(cityId)).value ?? [];
    final liveIds = liveNow.map((a) => a.id).toSet();

    for (final a in list) {
      // Exclude live now from sections to prevent duplication
      if (liveIds.contains(a.id)) continue;

      if (a.scheduledTime.isBefore(todayEnd)) {
        today.add(a);
      } else if (a.scheduledTime.isBefore(tomorrowEnd)) {
        tomorrow.add(a);
      } else if (a.scheduledTime.isBefore(weekEnd)) {
        thisWeek.add(a);
      } else {
        comingUp.add(a);
      }
    }

    return GroupedFeed(
      today: today,
      tomorrow: tomorrow,
      thisWeek: thisWeek,
      comingUp: comingUp,
    );
  });
});
