import '../../italy_admin_copilot/data/ufficio_product_services.dart';
import '../../italy_admin_copilot/domain/catalog_models.dart';
import '../domain/admin_models.dart';
import 'admin_repository.dart';

class LocalAdminRepository implements AdminRepository {
  const LocalAdminRepository();

  @override
  Future<AdminUserRow?> getCurrentAdminRow() async => null;

  @override
  Future<bool> isCurrentUserAdmin() async => false;

  @override
  Future<List<AdminAuditLog>> listAuditLogs() async => const [];

  @override
  Future<List<ConsultancyRequestRecord>> listConsultancyRequests() async =>
      const [];

  @override
  Future<List<AdminEntitlementRecord>> listEntitlements() async => const [];

  @override
  Future<List<OfficialContact>> listOfficialContacts() async => const [];

  @override
  Future<List<OfficialLink>> listOfficialLinks() async => const [];

  @override
  Future<List<ProblemRequestRecord>> listProblemRequests() async => const [];

  @override
  Future<List<ProcedureGuidance>> listProcedureGuidance() async => const [];

  @override
  Future<List<AdminPremiumEvent>> listPremiumEvents({String? userId}) async =>
      const [];

  @override
  Future<List<AdminUserRow>> listAdminUsers() async => const [];

  @override
  Future<Map<String, dynamic>> getPublicConfig() async => const {};

  @override
  Future<void> saveEntitlement(AdminEntitlementRecord record) async {}

  @override
  Future<void> savePublicConfig(Map<String, dynamic> values) async {}

  @override
  Future<void> updateConsultancyRequest(
    ConsultancyRequestRecord record,
  ) async {}

  @override
  Future<void> updateProblemRequest(ProblemRequestRecord record) async {}

  @override
  Future<void> upsertAdminUser({
    required String userId,
    required String email,
    required String role,
    required bool isActive,
  }) async {}

  @override
  Future<void> writeAuditLog({
    required String action,
    required String targetTable,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {}
}
