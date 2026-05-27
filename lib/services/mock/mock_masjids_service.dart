import 'dart:async';
import '../../models/masjid.dart';
import '../interfaces/masjids_interface.dart';
import 'mock_data.dart';

class MockMasjidsService implements IMasjidsService {
  static final _masjidsController = StreamController<List<Masjid>>.broadcast();
  
  // Local cache of followed masjids per user UID
  static final Map<String, List<String>> _userFollows = {};

  void _notifyListeners(String cityId) {
    final list = MockData.masjids
        .where((m) => m['cityId'] == cityId && (m['isActive'] as bool? ?? true))
        .map((m) => Masjid.fromMap(m, m['id'] as String))
        .toList();
    _masjidsController.add(list);
  }

  @override
  Stream<List<Masjid>> watchMasjids(String cityId) {
    Timer.run(() => _notifyListeners(cityId));
    return _masjidsController.stream;
  }

  @override
  Future<void> followMasjid({required String uid, required String masjidId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final follows = _userFollows.putIfAbsent(uid, () => []);
    if (!follows.contains(masjidId)) {
      follows.add(masjidId);
      
      // Increment follower count in mock data
      final idx = MockData.masjids.indexWhere((m) => m['id'] == masjidId);
      if (idx != -1) {
        MockData.masjids[idx]['followerCount'] = (MockData.masjids[idx]['followerCount'] as int) + 1;
        _notifyListeners(MockData.masjids[idx]['cityId'] as String);
      }
    }
  }

  @override
  Future<void> unfollowMasjid({required String uid, required String masjidId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final follows = _userFollows[uid];
    if (follows != null && follows.contains(masjidId)) {
      follows.remove(masjidId);
      
      // Decrement follower count in mock data
      final idx = MockData.masjids.indexWhere((m) => m['id'] == masjidId);
      if (idx != -1) {
        MockData.masjids[idx]['followerCount'] = (MockData.masjids[idx]['followerCount'] as int) - 1;
        _notifyListeners(MockData.masjids[idx]['cityId'] as String);
      }
    }
  }

  @override
  Future<List<String>> getFollowedMasjidIds(String uid) async {
    return _userFollows[uid] ?? [];
  }

  @override
  Future<void> createMasjid(Masjid masjid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.masjids.add(masjid.toMap()..['id'] = masjid.id);
    _notifyListeners(masjid.cityId);
  }
}
