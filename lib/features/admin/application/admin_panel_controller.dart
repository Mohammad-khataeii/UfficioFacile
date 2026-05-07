import 'package:flutter/foundation.dart';

import '../../italy_admin_copilot/data/ufficio_product_services.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

class AdminPanelController extends ChangeNotifier {
  AdminPanelController(this._repository);

  final AdminRepository _repository;

  bool isLoading = false;
  bool isAdmin = false;
  String? errorMessage;
  AdminDashboardStats? stats;
  List<AdminUserRow> adminUsers = const [];
  List<AdminEntitlementRecord> entitlements = const [];
  List<AdminPremiumEvent> premiumEvents = const [];
  List<AdminAuditLog> auditLogs = const [];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      isAdmin = await _repository.isCurrentUserAdmin();
      if (!isAdmin) return;
      adminUsers = await _repository.listAdminUsers();
      entitlements = await _repository.listEntitlements();
      final problemRequests = await _repository.listProblemRequests();
      final consultancyRequests = await _repository.listConsultancyRequests();
      final links = await _repository.listOfficialLinks();
      final contacts = await _repository.listOfficialContacts();
      final procedures = await _repository.listProcedureGuidance();
      auditLogs = await _repository.listAuditLogs();
      stats = AdminDashboardStats(
        adminCount: adminUsers.length,
        premiumCount: entitlements
            .where((item) => item.plan != 'free' && item.status == 'active')
            .length,
        openProblemRequests: problemRequests
            .where((item) => item.status == ProblemRequestStatus.newRequest)
            .length,
        openConsultancyRequests: consultancyRequests
            .where((item) => item.status == ConsultancyRequestStatus.newRequest)
            .length,
        catalogCounts: {
          'links': links.length,
          'contacts': contacts.length,
          'procedures': procedures.length,
        },
      );
    } catch (error) {
      errorMessage = '$error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveEntitlement(AdminEntitlementRecord record) async {
    await _repository.saveEntitlement(record);
    await _repository.writeAuditLog(
      action: 'update_entitlement',
      targetTable: 'ufficio_user_entitlements',
      targetId: record.userId,
      metadata: {'plan': record.plan, 'status': record.status},
    );
    await load();
  }

  Future<void> saveAdminUser({
    required String userId,
    required String email,
    required String role,
    required bool isActive,
  }) async {
    await _repository.upsertAdminUser(
      userId: userId,
      email: email,
      role: role,
      isActive: isActive,
    );
    await _repository.writeAuditLog(
      action: 'upsert_admin_user',
      targetTable: 'ufficio_admin_users',
      targetId: userId,
      metadata: {'role': role, 'isActive': isActive},
    );
    await load();
  }
}
