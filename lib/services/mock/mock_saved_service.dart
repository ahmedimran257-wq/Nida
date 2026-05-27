import '../interfaces/saved_interface.dart';

class MockSavedService implements ISavedService {
  // Local cache of saved announcement IDs per user UID
  static final Map<String, List<String>> _userSaved = {};
  static final Map<String, Map<String, int>> _savedReminders = {}; // userUid -> {announcementId -> minutesBefore}

  @override
  Future<void> saveAnnouncement({
    required String uid,
    required String announcementId,
    int? reminderMinutesBefore,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _userSaved.putIfAbsent(uid, () => []);
    if (!list.contains(announcementId)) {
      list.add(announcementId);
    }
    if (reminderMinutesBefore != null) {
      final userR = _savedReminders.putIfAbsent(uid, () => {});
      userR[announcementId] = reminderMinutesBefore;
    }
  }

  @override
  Future<void> removeSavedAnnouncement({
    required String uid,
    required String announcementId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _userSaved[uid]?.remove(announcementId);
    _savedReminders[uid]?.remove(announcementId);
  }

  @override
  Future<List<String>> getSavedAnnouncementIds(String uid) async {
    return _userSaved[uid] ?? [];
  }
}
