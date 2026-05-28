import '../../models/announcement.dart';

abstract class IAnnouncementsService {
  Stream<List<Announcement>> watchActiveAnnouncements(String cityId);
  Stream<List<Announcement>> watchMasjidAnnouncements(String masjidId);
  Future<List<Announcement>> searchAnnouncements({required String cityId, required String query});
  Future<void> reportAnnouncement(String announcementId, String uid);
  Future<void> createAnnouncement(Announcement announcement);
  Future<void> updateAnnouncement(Announcement announcement);
  Future<void> deleteAnnouncement(String announcementId);
  Future<List<Announcement>> getAnnouncementsByAdmin(String adminId);
  Future<Announcement?> getAnnouncementById(String id);
}

