import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/masjid.dart';
import '../services/service_locator.dart';
import 'preferences_provider.dart';

// Stream of masjids in a city
final masjidsProvider = StreamProvider.family<List<Masjid>, String>((ref, cityId) {
  return masjidsService.watchMasjids(cityId);
});

// Followed Masjids provider, resolving Masjid model list
final followedMasjidsListProvider = Provider.family<AsyncValue<List<Masjid>>, String>((ref, cityId) {
  final masjidsAsync = ref.watch(masjidsProvider(cityId));
  final prefs = ref.watch(preferencesProvider);

  return masjidsAsync.whenData((list) {
    return list.where((m) => prefs.followedMasjids.contains(m.id)).toList();
  });
});

// Follow actions helper
class MasjidFollowAction {
  final Ref _ref;
  MasjidFollowAction(this._ref);

  Future<void> toggleFollow(String masjidId) async {
    final prefs = _ref.read(preferencesProvider);
    final uid = prefs.anonymousUid;
    
    // First update preference local state
    await _ref.read(preferencesProvider.notifier).toggleFollowMasjid(masjidId);
    
    // Check if we followed or unfollowed
    final updatedPrefs = _ref.read(preferencesProvider);
    final isFollowing = updatedPrefs.followedMasjids.contains(masjidId);

    if (isFollowing) {
      await masjidsService.followMasjid(uid: uid, masjidId: masjidId);
    } else {
      await masjidsService.unfollowMasjid(uid: uid, masjidId: masjidId);
    }
  }
}

final masjidFollowActionProvider = Provider<MasjidFollowAction>((ref) {
  return MasjidFollowAction(ref);
});
