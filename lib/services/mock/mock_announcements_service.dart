import 'dart:async';
import '../../models/announcement.dart';
import '../interfaces/announcements_interface.dart';
import 'mock_data.dart';

class MockAnnouncementsService implements IAnnouncementsService {
  // Broadcasters for stream subscriptions
  static final _activeController = StreamController<List<Announcement>>.broadcast();
  static final _masjidControllers = <String, StreamController<List<Announcement>>>{};

  DateTime _parseDate(dynamic val) {
    if (val is DateTime) return val;
    if (val is String) return DateTime.parse(val);
    return DateTime.now();
  }

  void _notifyListeners(String cityId, String? masjidId) {
    // Notify general feed
    final now = DateTime.now();
    final active = MockData.announcements
        .where((a) =>
            a['cityId'] == cityId &&
            !(a['isHidden'] as bool) &&
            _parseDate(a['expiresAt']).isAfter(now))
        .map((a) => Announcement.fromMockMap(a))
        .toList();
    _activeController.add(active);

    // Notify masjid specific feed if provided
    if (masjidId != null) {
      final masjidAnnouncements = MockData.announcements
          .where((a) =>
              a['masjidId'] == masjidId &&
              !(a['isHidden'] as bool) &&
              _parseDate(a['expiresAt']).isAfter(now))
          .map((a) => Announcement.fromMockMap(a))
          .toList();
      _masjidControllers[masjidId]?.add(masjidAnnouncements);
    }
  }

  @override
  Stream<List<Announcement>> watchActiveAnnouncements(String cityId) {
    // Emit initial values immediately
    Timer.run(() => _notifyListeners(cityId, null));
    return _activeController.stream;
  }

  @override
  Stream<List<Announcement>> watchMasjidAnnouncements(String masjidId) {
    final controller = _masjidControllers.putIfAbsent(
      masjidId,
      () => StreamController<List<Announcement>>.broadcast(),
    );
    // Find cityId to trigger initial notifications
    final cityId = MockData.masjids.firstWhere((m) => m['id'] == masjidId)['cityId'] as String;
    Timer.run(() => _notifyListeners(cityId, masjidId));
    return controller.stream;
  }

  @override
  Future<List<Announcement>> searchAnnouncements({
    required String cityId,
    required String query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150)); // simulate latency
    final lq = query.toLowerCase();
    final now = DateTime.now();
    return MockData.announcements
        .where((a) =>
            a['cityId'] == cityId &&
            !(a['isHidden'] as bool) &&
            _parseDate(a['expiresAt']).isAfter(now) &&
            ((a['scholarNameSnapshot'] as String? ?? '').toLowerCase().contains(lq) ||
             (a['masjidNameSnapshot'] as String? ?? '').toLowerCase().contains(lq) ||
             (a['title'] as String? ?? '').toLowerCase().contains(lq) ||
             (a['masjidLocalitySnapshot'] as String? ?? '').toLowerCase().contains(lq)))
        .map((a) => Announcement.fromMockMap(a))
        .toList();
  }

  @override
  Future<void> reportAnnouncement(String announcementId, String uid) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = MockData.announcements.indexWhere((a) => a['id'] == announcementId);
    if (idx != -ShortIntMax.round()) {
      final a = MockData.announcements[idx];
      final List<String> reportedUids = List<String>.from(a['reportedByUids'] ?? []);
      if (!reportedUids.contains(uid)) {
        reportedUids.add(uid);
        a['reportedByUids'] = reportedUids;
        a['reportCount'] = (a['reportCount'] as int) + 1;
        if ((a['reportCount'] as int) >= 3) {
          a['isFlaggedForReview'] = true;
          // Note: Spec says DO NOT auto-hide, just flag for Super Admin review
        }
        _notifyListeners(a['cityId'] as String, a['masjidId'] as String);
      }
    }
  }

  @override
  Future<void> createAnnouncement(Announcement announcement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.announcements.add(announcement.toMap()..['id'] = announcement.id);
    _notifyListeners(announcement.cityId, announcement.masjidId);
  }

  @override
  Future<void> updateAnnouncement(Announcement announcement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = MockData.announcements.indexWhere((a) => a['id'] == announcement.id);
    if (idx != -1) {
      MockData.announcements[idx] = announcement.toMap()..['id'] = announcement.id;
      _notifyListeners(announcement.cityId, announcement.masjidId);
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = MockData.announcements.indexWhere((a) => a['id'] == announcementId);
    if (idx != -1) {
      final cityId = MockData.announcements[idx]['cityId'] as String;
      final masjidId = MockData.announcements[idx]['masjidId'] as String?;
      MockData.announcements.removeAt(idx);
      _notifyListeners(cityId, masjidId);
    }
  }

  @override
  Future<List<Announcement>> getAnnouncementsByAdmin(String adminId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockData.announcements
        .where((a) => a['postedBy'] == adminId)
        .map((a) => Announcement.fromMockMap(a))
        .toList();
  }

  @override
  Future<Announcement?> getAnnouncementById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = MockData.announcements.indexWhere((a) => a['id'] == id);
    if (idx != -1) {
      return Announcement.fromMockMap(MockData.announcements[idx]);
    }
    return null;
  }
}
// Stub constant to replace missing reference
const int ShortIntMax = 32767;
