abstract class ISavedService {
  Future<void> saveAnnouncement({required String uid, required String announcementId, int? reminderMinutesBefore});
  Future<void> removeSavedAnnouncement({required String uid, required String announcementId});
  Future<List<String>> getSavedAnnouncementIds(String uid);
}
