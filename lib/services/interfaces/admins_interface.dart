abstract class IAdminsService {
  Future<List<Map<String, dynamic>>> getAdminsByCity(String cityId);
  Future<String?> inviteAdmin({
    required String name,
    required String phone,
    required String cityId,
    required String addedBy,
  });
  Future<String?> softDeactivateAdmin({
    required String adminId,
    required String deactivatedBy,
  });
  Future<void> submitAdminRequest({
    required String name,
    required String phone,
    required String masjidName,
    required String cityName,
    String? note,
  });
  Future<List<Map<String, dynamic>>> getPendingAdminRequests();
  Future<void> updateAdminRequestStatus(String requestId, String status);
  Future<void> suspendAdminGlobal(String adminId);
  Future<List<Map<String, dynamic>>> getAuditLogs();
  Future<void> addAuditLog({required String action, required String performedBy});
}
