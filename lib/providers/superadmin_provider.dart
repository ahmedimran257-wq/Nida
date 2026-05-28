import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement.dart';
import '../services/mock/mock_data.dart';
import '../services/service_locator.dart';

class SuperAdminState {
  final bool isLoggedIn;
  final List<Map<String, dynamic>> pendingRequests;
  final List<Announcement> flaggedAnnouncements;
  final List<Map<String, dynamic>> cities;
  final List<Map<String, dynamic>> auditLogs;
  final String? error;

  const SuperAdminState({
    this.isLoggedIn = false,
    this.pendingRequests = const [],
    this.flaggedAnnouncements = const [],
    this.cities = const [],
    this.auditLogs = const [],
    this.error,
  });

  SuperAdminState copyWith({
    bool? isLoggedIn,
    List<Map<String, dynamic>>? pendingRequests,
    List<Announcement>? flaggedAnnouncements,
    List<Map<String, dynamic>>? cities,
    List<Map<String, dynamic>>? auditLogs,
    String? error,
  }) {
    return SuperAdminState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      flaggedAnnouncements: flaggedAnnouncements ?? this.flaggedAnnouncements,
      cities: cities ?? this.cities,
      auditLogs: auditLogs ?? this.auditLogs,
      error: error,
    );
  }
}

class SuperAdminNotifier extends StateNotifier<SuperAdminState> {
  SuperAdminNotifier() : super(const SuperAdminState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(error: null);
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim() == MockData.superAdminEmail && password == MockData.superAdminPassword) {
      await adminsService.addAuditLog(action: 'Super Admin Login', performedBy: 'superAdmin');
      state = state.copyWith(isLoggedIn: true);
      await loadData();
      return true;
    } else {
      state = state.copyWith(error: 'Invalid Super Admin credentials.');
      return false;
    }
  }

  void logout() {
    adminsService.addAuditLog(action: 'Super Admin Logout', performedBy: 'superAdmin');
    state = const SuperAdminState();
  }

  Future<void> loadData() async {
    if (!state.isLoggedIn) return;
    
    final requests = await adminsService.getPendingAdminRequests();
    
    // Fetch all active/inactive cities
    final citiesList = await citiesService.searchCities('');
    final citiesMapped = citiesList.map((c) => {
      'id': c.id,
      'cityName': c.cityName,
      'state': c.state,
      'country': c.country,
      'countryCode': c.countryCode,
      'isActive': c.isActive,
      'calculationMethod': c.calculationMethod,
      'timezone': c.timezone,
      'adminCount': c.adminCount,
      'maxAdmins': c.maxAdmins,
    }).toList();

    // Query flagged announcements
    // We can fetch announcements by doing query on mock data, but wait: announcementsService doesn't have a broad list method,
    // so we can query them from MockData directly for mock Super Admin purposes, or add a method.
    // Let's directly filter flagged announcements from MockData for mock convenience
    final flagged = MockData.announcements
        .where((a) => a['isFlaggedForReview'] == true)
        .map((a) => Announcement.fromMockMap(a))
        .toList();

    final logs = await adminsService.getAuditLogs();

    state = state.copyWith(
      pendingRequests: requests,
      flaggedAnnouncements: flagged,
      cities: citiesMapped,
      auditLogs: List.from(logs.reversed), // newest first
    );
  }

  Future<void> approveAdminRequest(String requestId) async {
    final reqIdx = MockData.adminRequests.indexWhere((r) => r['id'] == requestId);
    if (reqIdx == -1) return;

    final request = MockData.adminRequests[reqIdx];
    
    // Set request status
    await adminsService.updateAdminRequestStatus(requestId, 'approved');

    // Add active admin in city
    final hashedPhone = MockData.hashPhone(request['phone'] as String);
    MockData.imamAdmins.add({
      'id': 'admin_00${MockData.imamAdmins.length + 1}',
      'name': request['name'] as String,
      'phone': hashedPhone,
      'phoneDisplay': '****${request['phone'].toString().substring(request['phone'].toString().length - 4)}',
      'cityId': request['cityId'] as String,
      'addedBy': 'superAdmin',
      'addedVia': 'request_approval',
      'isActive': true,
      'announcementsPosted': 0,
      'createdAt': DateTime.now(),
    });

    // Automatically set city to active when first admin is approved
    final cityIdx = MockData.cities.indexWhere((c) => c['id'] == request['cityId']);
    if (cityIdx != -1) {
      MockData.cities[cityIdx]['isActive'] = true;
      MockData.cities[cityIdx]['adminCount'] = (MockData.cities[cityIdx]['adminCount'] as int) + 1;
    }

    await adminsService.addAuditLog(
      action: 'Approved Admin request ${request['name']} for ${request['masjidName']}',
      performedBy: 'superAdmin',
    );

    await loadData();
  }

  Future<void> rejectAdminRequest(String requestId) async {
    final reqIdx = MockData.adminRequests.indexWhere((r) => r['id'] == requestId);
    if (reqIdx == -1) return;
    final request = MockData.adminRequests[reqIdx];

    await adminsService.updateAdminRequestStatus(requestId, 'rejected');

    await adminsService.addAuditLog(
      action: 'Rejected Admin request ${request['name']}',
      performedBy: 'superAdmin',
    );

    await loadData();
  }

  Future<void> hideAnnouncement(String announcementId) async {
    final idx = MockData.announcements.indexWhere((a) => a['id'] == announcementId);
    if (idx != -1) {
      MockData.announcements[idx]['isHidden'] = true;
      MockData.announcements[idx]['isFlaggedForReview'] = false;
      
      await adminsService.addAuditLog(
        action: 'Moderation: Hid announcement "${MockData.announcements[idx]['title']}"',
        performedBy: 'superAdmin',
      );
    }
    await loadData();
  }

  Future<void> dismissFlaggedAnnouncement(String announcementId) async {
    final idx = MockData.announcements.indexWhere((a) => a['id'] == announcementId);
    if (idx != -1) {
      MockData.announcements[idx]['isFlaggedForReview'] = false;
      MockData.announcements[idx]['reportCount'] = 0;
      MockData.announcements[idx]['reportedByUids'] = <String>[];
      
      await adminsService.addAuditLog(
        action: 'Moderation: Dismissed reports for "${MockData.announcements[idx]['title']}"',
        performedBy: 'superAdmin',
      );
    }
    await loadData();
  }

  Future<void> toggleCityActivation(String cityId, bool isActive) async {
    final idx = MockData.cities.indexWhere((c) => c['id'] == cityId);
    if (idx != -1) {
      MockData.cities[idx]['isActive'] = isActive;
      
      await adminsService.addAuditLog(
        action: 'City Control: Set ${MockData.cities[idx]['cityName']} isActive to $isActive',
        performedBy: 'superAdmin',
      );
    }
    await loadData();
  }

  Future<void> suspendAdminGlobal(String adminId) async {
    await adminsService.suspendAdminGlobal(adminId);
    
    final admin = MockData.imamAdmins.firstWhere((a) => a['id'] == adminId);
    await adminsService.addAuditLog(
      action: 'Suspended Coordinator ${admin['name']}',
      performedBy: 'superAdmin',
    );
    await loadData();
  }
}

final superAdminProvider = StateNotifierProvider<SuperAdminNotifier, SuperAdminState>(
  (ref) => SuperAdminNotifier(),
);
