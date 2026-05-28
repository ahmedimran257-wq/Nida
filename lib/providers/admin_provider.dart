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
    return adminsService.inviteAdmin(
      name: name,
      phone: phone,
      cityId: state.cityId!,
      addedBy: state.adminId!,
    );
  }

  // Soft Deactivate Admin (slots bottleneck fix)
  Future<String?> softDeactivateAdmin(String targetAdminId) async {
    if (!state.isLoggedIn) return 'Not authenticated';
    if (targetAdminId == state.adminId) return 'Cannot deactivate yourself.';
    return adminsService.softDeactivateAdmin(
      adminId: targetAdminId,
      deactivatedBy: state.adminId!,
    );
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});
