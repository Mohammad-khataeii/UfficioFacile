import '../../italy_admin_copilot/data/ufficio_product_services.dart';
import '../../italy_admin_copilot/domain/catalog_models.dart';
import '../domain/admin_models.dart';

abstract class AdminRepository {
  Future<bool> isCurrentUserAdmin();
  Future<AdminUserRow?> getCurrentAdminRow();
  Future<List<AdminUserRow>> listAdminUsers();
  Future<void> upsertAdminUser({
    required String userId,
    required String email,
    required String role,
    required bool isActive,
  });
  Future<List<AdminEntitlementRecord>> listEntitlements();
  Future<void> saveEntitlement(AdminEntitlementRecord record);
  Future<List<AdminPremiumEvent>> listPremiumEvents({String? userId});
  Future<List<ProblemRequestRecord>> listProblemRequests();
  Future<void> updateProblemRequest(ProblemRequestRecord record);
  Future<List<ConsultancyRequestRecord>> listConsultancyRequests();
  Future<void> updateConsultancyRequest(ConsultancyRequestRecord record);
  Future<Map<String, dynamic>> getPublicConfig();
  Future<void> savePublicConfig(Map<String, dynamic> values);
  Future<List<OfficialLink>> listOfficialLinks();
  Future<List<OfficialContact>> listOfficialContacts();
  Future<List<ProcedureGuidance>> listProcedureGuidance();
  Future<List<AdminAuditLog>> listAuditLogs();
  Future<void> writeAuditLog({
    required String action,
    required String targetTable,
    String? targetId,
    Map<String, dynamic> metadata,
  });
}
