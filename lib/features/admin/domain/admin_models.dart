class AdminUserRow {
  const AdminUserRow({
    required this.userId,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.createdBy,
  });

  final String userId;
  final String? email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;

  factory AdminUserRow.fromJson(Map<String, dynamic> json) => AdminUserRow(
    userId: json['user_id'] as String? ?? '',
    email: json['email'] as String?,
    role: json['role'] as String? ?? 'viewer',
    isActive: json['is_active'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    createdBy: json['created_by'] as String?,
  );
}

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.adminCount,
    required this.premiumCount,
    required this.openProblemRequests,
    required this.openConsultancyRequests,
    required this.catalogCounts,
  });

  final int adminCount;
  final int premiumCount;
  final int openProblemRequests;
  final int openConsultancyRequests;
  final Map<String, int> catalogCounts;
}

class AdminEntitlementRecord {
  const AdminEntitlementRecord({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.source,
    this.currentPeriodEnd,
    this.premiumSince,
    this.metadata = const {},
  });

  final String id;
  final String userId;
  final String plan;
  final String status;
  final String source;
  final DateTime? currentPeriodEnd;
  final DateTime? premiumSince;
  final Map<String, dynamic> metadata;

  factory AdminEntitlementRecord.fromJson(Map<String, dynamic> json) =>
      AdminEntitlementRecord(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        plan: json['plan'] as String? ?? 'free',
        status: json['status'] as String? ?? 'active',
        source: json['source'] as String? ?? 'manual',
        currentPeriodEnd: DateTime.tryParse(
          json['current_period_end'] as String? ?? '',
        ),
        premiumSince: DateTime.tryParse(json['premium_since'] as String? ?? ''),
        metadata: Map<String, dynamic>.from(
          (json['metadata'] as Map?) ?? const {},
        ),
      );
}

class AdminPremiumEvent {
  const AdminPremiumEvent({
    required this.id,
    required this.eventType,
    required this.source,
    required this.payload,
    required this.createdAt,
    this.userId,
  });

  final String id;
  final String? userId;
  final String eventType;
  final String source;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  factory AdminPremiumEvent.fromJson(Map<String, dynamic> json) =>
      AdminPremiumEvent(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String?,
        eventType: json['event_type'] as String? ?? '',
        source: json['source'] as String? ?? '',
        payload: Map<String, dynamic>.from(
          (json['payload'] as Map?) ?? const {},
        ),
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

class AdminAuditLog {
  const AdminAuditLog({
    required this.id,
    required this.action,
    required this.targetTable,
    required this.createdAt,
    this.actorUserId,
    this.targetId,
    this.metadata = const {},
  });

  final String id;
  final String? actorUserId;
  final String action;
  final String targetTable;
  final String? targetId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) => AdminAuditLog(
    id: json['id'] as String? ?? '',
    actorUserId: json['actor_user_id'] as String?,
    action: json['action'] as String? ?? '',
    targetTable: json['target_table'] as String? ?? '',
    targetId: json['target_id'] as String?,
    metadata: Map<String, dynamic>.from((json['metadata'] as Map?) ?? const {}),
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
  );
}
