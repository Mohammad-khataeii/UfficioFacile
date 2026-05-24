import 'package:supabase_flutter/supabase_flutter.dart';

import '../../italy_admin_copilot/data/supabase_catalog_repository.dart';
import '../../italy_admin_copilot/data/ufficio_product_services.dart';
import '../../italy_admin_copilot/domain/catalog_models.dart';
import '../domain/admin_models.dart';
import 'admin_repository.dart';

class SupabaseAdminRepository implements AdminRepository {
  SupabaseAdminRepository(this._client)
    : _catalog = SupabaseCatalogRepository(_client);

  final SupabaseClient _client;
  final SupabaseCatalogRepository _catalog;

  @override
  Future<bool> isCurrentUserAdmin() async {
    final result = await _client.rpc('is_ufficio_admin');
    return result == true;
  }

  @override
  Future<AdminUserRow?> getCurrentAdminRow() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('ufficio_admin_users')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return AdminUserRow.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<List<AdminUserRow>> listAdminUsers() async {
    final rows = await _client
        .from('ufficio_admin_users')
        .select()
        .order('created_at');
    return rows
        .map((item) => AdminUserRow.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> upsertAdminUser({
    required String userId,
    required String email,
    required String role,
    required bool isActive,
  }) async {
    await _client.from('ufficio_admin_users').upsert({
      'user_id': userId,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_by': _client.auth.currentUser?.id,
    });
  }

  @override
  Future<List<AdminEntitlementRecord>> listEntitlements() async {
    final rows = await _client
        .from('ufficio_user_entitlements')
        .select()
        .order('updated_at', ascending: false);
    return rows
        .map(
          (item) =>
              AdminEntitlementRecord.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<void> saveEntitlement(AdminEntitlementRecord record) async {
    await _client.from('ufficio_user_entitlements').upsert({
      'id': record.id.isEmpty ? null : record.id,
      'user_id': record.userId,
      'plan': record.plan,
      'status': record.status,
      'source': record.source,
      'current_period_end': record.currentPeriodEnd?.toIso8601String(),
      'premium_since': record.premiumSince?.toIso8601String(),
      'metadata': record.metadata,
    });
  }

  @override
  Future<List<AdminPremiumEvent>> listPremiumEvents({String? userId}) async {
    final rows = userId != null && userId.isNotEmpty
        ? await _client
              .from('ufficio_premium_events')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
        : await _client
              .from('ufficio_premium_events')
              .select()
              .order('created_at', ascending: false);
    return rows
        .map(
          (item) => AdminPremiumEvent.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<List<ProblemRequestRecord>> listProblemRequests() async {
    final rows = await _client
        .from('ufficio_problem_requests')
        .select()
        .order('created_at', ascending: false);
    return rows.map((item) {
      final row = Map<String, dynamic>.from(item);
      return ProblemRequestRecord(
        id: row['id'] as String,
        userId: row['user_id'] as String?,
        userEmail: row['email'] as String?,
        categoryId: row['category'] as String?,
        title: row['problem_title'] as String? ?? '',
        description: row['problem_description'] as String? ?? '',
        city: 'Torino',
        region: 'Piemonte',
        urgency: 'normal',
        language: row['language_code'] as String? ?? 'en',
        status: problemRequestStatusFromJson(row['status'] as String?),
        isPremiumUser: false,
        sourcePage: 'supabase',
        createdAt:
            DateTime.tryParse(row['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(row['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> updateProblemRequest(ProblemRequestRecord record) async {
    await _client
        .from('ufficio_problem_requests')
        .update({
          'status': switch (record.status) {
            ProblemRequestStatus.newRequest => 'new',
            ProblemRequestStatus.reviewing => 'reviewing',
            ProblemRequestStatus.planned => 'planned',
            ProblemRequestStatus.added => 'added',
            ProblemRequestStatus.rejected => 'rejected',
          },
          'admin_notes': record.description,
        })
        .eq('id', record.id);
  }

  @override
  Future<List<ConsultancyRequestRecord>> listConsultancyRequests() async {
    final rows = await _client
        .from('ufficio_consultancy_requests')
        .select()
        .order('created_at', ascending: false);
    return rows.map((item) {
      final row = Map<String, dynamic>.from(item);
      return ConsultancyRequestRecord(
        id: row['id'] as String,
        userId: row['user_id'] as String?,
        userEmail: row['user_email'] as String? ?? row['email'] as String?,
        fullName:
            row['full_name'] as String? ??
            row['user_email'] as String? ??
            row['email'] as String? ??
            '',
        categoryId: row['category_id'] as String? ?? row['category'] as String?,
        problemType:
            row['problem_type'] as String? ?? row['subject'] as String? ?? '',
        description:
            row['description'] as String? ?? row['message'] as String? ?? '',
        desiredResult:
            row['desired_result'] as String? ??
            row['admin_notes'] as String? ??
            '',
        city: row['city'] as String? ?? 'Torino',
        region: row['region'] as String? ?? 'Piemonte',
        documentsAvailable: row['documents_available'] as String? ?? '',
        userPlan:
            row['user_plan'] as String? ??
            (row['is_premium_snapshot'] == true ? 'premium' : 'free'),
        paymentStatus: consultancyPaymentStatusFromJson(
          row['payment_status'] as String?,
        ),
        status: consultancyRequestStatusFromJson(row['status'] as String?),
        sourcePage: row['source_page'] as String? ?? 'supabase',
        createdAt:
            DateTime.tryParse(row['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(row['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> updateConsultancyRequest(ConsultancyRequestRecord record) async {
    await _client
        .from('ufficio_consultancy_requests')
        .update({
          'status': switch (record.status) {
            ConsultancyRequestStatus.newRequest => 'new',
            ConsultancyRequestStatus.waitingPayment => 'waiting_user',
            ConsultancyRequestStatus.reviewing => 'reviewing',
            ConsultancyRequestStatus.replied => 'answered',
            ConsultancyRequestStatus.closed => 'closed',
          },
          'payment_status': switch (record.paymentStatus) {
            ConsultancyPaymentStatus.freeForPremium => 'not_required',
            ConsultancyPaymentStatus.paymentRequired => 'required',
            ConsultancyPaymentStatus.waitingPayment => 'pending',
            ConsultancyPaymentStatus.paid => 'paid',
            ConsultancyPaymentStatus.failed => 'failed',
            ConsultancyPaymentStatus.notAvailable => 'waived',
          },
          'admin_notes': record.desiredResult,
        })
        .eq('id', record.id);
  }

  @override
  Future<Map<String, dynamic>> getPublicConfig() =>
      _catalog.getAppPublicConfig();

  @override
  Future<void> savePublicConfig(Map<String, dynamic> values) async {
    for (final entry in values.entries) {
      await _client.from('ufficio_app_public_config').upsert({
        'key': entry.key,
        'value': entry.value,
        'is_active': true,
      });
    }
  }

  @override
  Future<List<OfficialLink>> listOfficialLinks() =>
      _catalog.listOfficialLinks();

  @override
  Future<List<OfficialContact>> listOfficialContacts() =>
      _catalog.listOfficialContacts();

  @override
  Future<List<ProcedureGuidance>> listProcedureGuidance() =>
      _catalog.listProcedureGuidance();

  @override
  Future<List<AdminAuditLog>> listAuditLogs() async {
    final rows = await _client
        .from('ufficio_admin_audit_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return rows
        .map((item) => AdminAuditLog.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> writeAuditLog({
    required String action,
    required String targetTable,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _client.from('ufficio_admin_audit_logs').insert({
      'actor_user_id': _client.auth.currentUser?.id,
      'action': action,
      'target_table': targetTable,
      'target_id': targetId,
      'metadata': metadata,
    });
  }
}
