import '../../services/interfaces/admins_interface.dart';
import 'mock_data.dart';

class MockAdminsService implements IAdminsService {
  @override
  Future<List<Map<String, dynamic>>> getAdminsByCity(String cityId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockData.imamAdmins.where((a) => a['cityId'] == cityId).toList();
  }

  @override
  Future<String?> inviteAdmin({
    required String name,
    required String phone,
    required String cityId,
    required String addedBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final cityAdmins = MockData.imamAdmins.where((a) => a['cityId'] == cityId && a['isActive'] == true).length;
    if (cityAdmins >= 10) {
      return 'Admin limit reached. Contact the app owner.';
    }

    final hashed = MockData.hashPhone(phone);
    final exists = MockData.imamAdmins.any((a) => a['phone'] == hashed);
    if (exists) {
      return 'Admin phone number already registered.';
    }

    MockData.imamAdmins.add({
      'id': 'admin_00${MockData.imamAdmins.length + 1}',
      'name': name,
      'phone': hashed,
      'phoneDisplay': '****${phone.substring(phone.length - 4)}',
      'cityId': cityId,
      'addedBy': addedBy,
      'addedVia': 'whatsapp_model',
      'isActive': true,
      'announcementsPosted': 0,
      'createdAt': DateTime.now(),
    });

    return null;
  }

  @override
  Future<String?> softDeactivateAdmin({
    required String adminId,
    required String deactivatedBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final idx = MockData.imamAdmins.indexWhere((a) => a['id'] == adminId);
    if (idx == -1) return 'Admin not found.';

    final target = MockData.imamAdmins[idx];
    final cityId = target['cityId'] as String;

    final cityAdminsCount = MockData.imamAdmins.where((a) => a['cityId'] == cityId && a['isActive'] == true).length;
    if (cityAdminsCount <= 2) {
      return 'Cannot deactivate. Minimum 2 active admins must remain in the city.';
    }

    target['isActive'] = false;
    target['deactivatedBy'] = deactivatedBy;
    target['deactivatedAt'] = DateTime.now();

    return null;
  }

  @override
  Future<void> submitAdminRequest({
    required String name,
    required String phone,
    required String masjidName,
    required String cityName,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    MockData.adminRequests.add({
      'id': 'req_00${MockData.adminRequests.length + 1}',
      'name': name,
      'phone': phone,
      'masjidName': masjidName,
      'cityId': '${cityName.toLowerCase().replaceAll(' ', '_')}_in', // Generate clean cityId
      'cityName': cityName,
      'countryCode': 'IN', // Default, updated on approval if needed
      'note': note ?? '',
      'status': 'pending',
      'submittedAt': DateTime.now(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingAdminRequests() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockData.adminRequests.where((r) => r['status'] == 'pending').toList();
  }

  @override
  Future<void> updateAdminRequestStatus(String requestId, String status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = MockData.adminRequests.indexWhere((r) => r['id'] == requestId);
    if (idx != -1) {
      MockData.adminRequests[idx]['status'] = status;
    }
  }

  @override
  Future<void> suspendAdminGlobal(String adminId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = MockData.imamAdmins.indexWhere((a) => a['id'] == adminId);
    if (idx != -1) {
      MockData.imamAdmins[idx]['isActive'] = false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockData.auditLogs;
  }

  @override
  Future<void> addAuditLog({required String action, required String performedBy}) async {
    MockData.auditLogs.add({
      'id': 'log_00${MockData.auditLogs.length + 1}',
      'action': action,
      'performedBy': performedBy,
      'timestamp': DateTime.now(),
    });
  }
}
