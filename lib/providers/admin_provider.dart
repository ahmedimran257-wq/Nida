import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/announcement.dart';
import '../../models/masjid.dart';
import '../../models/scholar.dart';
import '../services/mock/mock_data.dart';
import '../services/service_locator.dart';

class AdminState {
  final bool isLoggedIn;
  final String? adminId;
  final String? adminName;
  final String? cityId;
  final String? error;

  AdminState({
    required this.isLoggedIn,
    this.adminId,
    this.adminName,
    this.cityId,
    this.error,
  });

  AdminState copyWith({
    bool? isLoggedIn,
    String? adminId,
    String? adminName,
    String? cityId,
    String? error,
  }) {
    return AdminState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      cityId: cityId ?? this.cityId,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(AdminState(isLoggedIn: false));

  Future<bool> login(String phoneNumber) async {
    state = state.copyWith(error: null);
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network delay

    final hashed = MockData.hashPhone(phoneNumber);
    final idx = MockData.imamAdmins.indexWhere((a) => a['phone'] == hashed && a['isActive'] == true);

    if (idx != -1) {
      final admin = MockData.imamAdmins[idx];
      state = AdminState(
        isLoggedIn: true,
        adminId: admin['id'] as String,
        adminName: admin['name'] as String,
        cityId: admin['cityId'] as String,
      );
      return true;
    } else {
      state = state.copyWith(error: 'Your number is not registered as an active admin.');
      return false;
    }
  }

  void logout() {
    state = AdminState(isLoggedIn: false);
  }

  // Admin Actions
  Future<void> postAnnouncement(Announcement announcement) async {
    if (!state.isLoggedIn) return;
    await announcementsService.createAnnouncement(announcement);
    
    // Update admin stats in-memory
    final idx = MockData.imamAdmins.indexWhere((a) => a['id'] == state.adminId);
    if (idx != -1) {
      MockData.imamAdmins[idx]['announcementsPosted'] = (MockData.imamAdmins[idx]['announcementsPosted'] as int) + 1;
    }
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    if (!state.isLoggedIn) return;
    await announcementsService.updateAnnouncement(announcement);
  }

  Future<void> createScholar(Scholar scholar) async {
    if (!state.isLoggedIn) return;
    await scholarsService.createScholar(scholar);
  }

  Future<void> createMasjid(Masjid masjid) async {
    if (!state.isLoggedIn) return;
    await masjidsService.createMasjid(masjid);
  }

  // Invite new Admin
  Future<String?> inviteAdmin(String name, String phone) async {
    if (!state.isLoggedIn) return 'Not authenticated';
    
    // Count active admins in city
    final cityAdmins = MockData.imamAdmins.where((a) => a['cityId'] == state.cityId && a['isActive'] == true).length;
    if (cityAdmins >= 10) {
      return 'Admin limit reached. Contact the app owner.';
    }

    final hashed = MockData.hashPhone(phone);
    final exists = MockData.imamAdmins.any((a) => a['phone'] == hashed);
    if (exists) {
      return 'Admin phone number already registered.';
    }

    // Add to pending admins in mock and directly create active admin for simulation ease
    MockData.imamAdmins.add({
      'id': 'admin_00${MockData.imamAdmins.length + 1}',
      'name': name,
      'phone': hashed,
      'phoneDisplay': '****${phone.substring(phone.length - 4)}',
      'cityId': state.cityId!,
      'addedBy': state.adminId!,
      'addedVia': 'whatsapp_model',
      'isActive': true,
      'announcementsPosted': 0,
      'createdAt': DateTime.now(),
    });

    return null; // success
  }

  // Soft Deactivate Admin (slots bottleneck fix)
  Future<String?> softDeactivateAdmin(String targetAdminId) async {
    if (!state.isLoggedIn) return 'Not authenticated';
    if (targetAdminId == state.adminId) return 'Cannot deactivate yourself.';

    final idx = MockData.imamAdmins.indexWhere((a) => a['id'] == targetAdminId);
    if (idx == -1) return 'Admin not found.';

    final target = MockData.imamAdmins[idx];
    
    // Check condition: Must have 2+ active admins remaining in city
    final cityAdminsCount = MockData.imamAdmins.where((a) => a['cityId'] == state.cityId && a['isActive'] == true).length;
    if (cityAdminsCount <= 2) {
      return 'Cannot deactivate. Minimum 2 active admins must remain in the city.';
    }

    // Deactivate
    target['isActive'] = false;
    target['deactivatedBy'] = state.adminId;
    target['deactivatedAt'] = DateTime.now();

    return null; // success
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});
