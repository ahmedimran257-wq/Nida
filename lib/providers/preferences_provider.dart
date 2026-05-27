import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PreferencesState {
  final String? cityId;
  final List<String> followedMasjids;
  final List<String> savedAnnouncements;
  final bool isFirstLaunch;
  final String anonymousUid;
  final bool ramadanManualOverride;

  PreferencesState({
    this.cityId,
    required this.followedMasjids,
    required this.savedAnnouncements,
    required this.isFirstLaunch,
    required this.anonymousUid,
    this.ramadanManualOverride = false,
  });

  PreferencesState copyWith({
    String? cityId,
    List<String>? followedMasjids,
    List<String>? savedAnnouncements,
    bool? isFirstLaunch,
    String? anonymousUid,
    bool? ramadanManualOverride,
  }) {
    return PreferencesState(
      cityId: cityId ?? this.cityId,
      followedMasjids: followedMasjids ?? this.followedMasjids,
      savedAnnouncements: savedAnnouncements ?? this.savedAnnouncements,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      anonymousUid: anonymousUid ?? this.anonymousUid,
      ramadanManualOverride: ramadanManualOverride ?? this.ramadanManualOverride,
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(PreferencesState(
    followedMasjids: [],
    savedAnnouncements: [],
    isFirstLaunch: true,
    anonymousUid: '',
  )) {
    _loadPreferences();
  }

  static const String _cityKey = 'nida_city_id';
  static const String _followsKey = 'nida_followed_masjids';
  static const String _savedKey = 'nida_saved_announcements';
  static const String _firstLaunchKey = 'nida_first_launch';
  static const String _uidKey = 'nida_anonymous_uid';
  static const String _ramadanKey = 'nida_ramadan_override';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Generate an anonymous UID if not present (simulates Firebase Anonymous Auth)
    String uid = prefs.getString(_uidKey) ?? '';
    if (uid.isEmpty) {
      uid = const Uuid().v4();
      await prefs.setString(_uidKey, uid);
    }
    
    final cityId = prefs.getString(_cityKey);
    final followedMasjids = prefs.getStringList(_followsKey) ?? [];
    final savedAnnouncements = prefs.getStringList(_savedKey) ?? [];
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    final ramadanOverride = prefs.getBool(_ramadanKey) ?? false;

    state = PreferencesState(
      cityId: cityId,
      followedMasjids: followedMasjids,
      savedAnnouncements: savedAnnouncements,
      isFirstLaunch: isFirstLaunch,
      anonymousUid: uid,
      ramadanManualOverride: ramadanOverride,
    );
  }

  Future<void> setCityId(String? cityId) async {
    final prefs = await SharedPreferences.getInstance();
    if (cityId == null) {
      await prefs.remove(_cityKey);
    } else {
      await prefs.setString(_cityKey, cityId);
    }
    state = state.copyWith(cityId: cityId);
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
    state = state.copyWith(isFirstLaunch: false);
  }

  Future<void> toggleFollowMasjid(String masjidId) async {
    final list = List<String>.from(state.followedMasjids);
    if (list.contains(masjidId)) {
      list.remove(masjidId);
    } else {
      list.add(masjidId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_followsKey, list);
    state = state.copyWith(followedMasjids: list);
  }

  Future<void> toggleSaveAnnouncement(String announcementId) async {
    final list = List<String>.from(state.savedAnnouncements);
    if (list.contains(announcementId)) {
      list.remove(announcementId);
    } else {
      list.add(announcementId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, list);
    state = state.copyWith(savedAnnouncements: list);
  }

  Future<void> setRamadanOverride(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ramadanKey, value);
    state = state.copyWith(ramadanManualOverride: value);
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  return PreferencesNotifier();
});
