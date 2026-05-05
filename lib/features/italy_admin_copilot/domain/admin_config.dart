class AdminFeatureFlags {
  const AdminFeatureFlags({
    this.enableUtilities = true,
    this.enableCanoneRai = true,
    this.enableTelecom = true,
    this.enableAdminPanel = true,
    this.enableDemoData = true,
    this.enablePremiumFlags = false,
  });

  final bool enableUtilities;
  final bool enableCanoneRai;
  final bool enableTelecom;
  final bool enableAdminPanel;
  final bool enableDemoData;
  final bool enablePremiumFlags;

  AdminFeatureFlags copyWith({
    bool? enableUtilities,
    bool? enableCanoneRai,
    bool? enableTelecom,
    bool? enableAdminPanel,
    bool? enableDemoData,
    bool? enablePremiumFlags,
  }) {
    return AdminFeatureFlags(
      enableUtilities: enableUtilities ?? this.enableUtilities,
      enableCanoneRai: enableCanoneRai ?? this.enableCanoneRai,
      enableTelecom: enableTelecom ?? this.enableTelecom,
      enableAdminPanel: enableAdminPanel ?? this.enableAdminPanel,
      enableDemoData: enableDemoData ?? this.enableDemoData,
      enablePremiumFlags: enablePremiumFlags ?? this.enablePremiumFlags,
    );
  }

  Map<String, dynamic> toJson() => {
    'enableUtilities': enableUtilities,
    'enableCanoneRai': enableCanoneRai,
    'enableTelecom': enableTelecom,
    'enableAdminPanel': enableAdminPanel,
    'enableDemoData': enableDemoData,
    'enablePremiumFlags': enablePremiumFlags,
  };

  factory AdminFeatureFlags.fromJson(Map<String, dynamic> json) =>
      AdminFeatureFlags(
        enableUtilities: json['enableUtilities'] as bool? ?? true,
        enableCanoneRai: json['enableCanoneRai'] as bool? ?? true,
        enableTelecom: json['enableTelecom'] as bool? ?? true,
        enableAdminPanel: json['enableAdminPanel'] as bool? ?? true,
        enableDemoData: json['enableDemoData'] as bool? ?? true,
        enablePremiumFlags: json['enablePremiumFlags'] as bool? ?? false,
      );
}

class AdminConfig {
  const AdminConfig({
    this.freePackLimit = 3,
    this.premiumProcedureIds = const [],
    this.adminModeEnabled = false,
    this.featureFlags = const AdminFeatureFlags(),
  });

  final int freePackLimit;
  final List<String> premiumProcedureIds;
  final bool adminModeEnabled;
  final AdminFeatureFlags featureFlags;

  AdminConfig copyWith({
    int? freePackLimit,
    List<String>? premiumProcedureIds,
    bool? adminModeEnabled,
    AdminFeatureFlags? featureFlags,
  }) {
    return AdminConfig(
      freePackLimit: freePackLimit ?? this.freePackLimit,
      premiumProcedureIds: premiumProcedureIds ?? this.premiumProcedureIds,
      adminModeEnabled: adminModeEnabled ?? this.adminModeEnabled,
      featureFlags: featureFlags ?? this.featureFlags,
    );
  }

  Map<String, dynamic> toJson() => {
    'freePackLimit': freePackLimit,
    'premiumProcedureIds': premiumProcedureIds,
    'adminModeEnabled': adminModeEnabled,
    'featureFlags': featureFlags.toJson(),
  };

  factory AdminConfig.fromJson(Map<String, dynamic> json) => AdminConfig(
    freePackLimit: json['freePackLimit'] as int? ?? 3,
    premiumProcedureIds: ((json['premiumProcedureIds'] as List?) ?? [])
        .cast<String>(),
    adminModeEnabled: json['adminModeEnabled'] as bool? ?? false,
    featureFlags: json['featureFlags'] is Map
        ? AdminFeatureFlags.fromJson(
            Map<String, dynamic>.from(json['featureFlags'] as Map),
          )
        : const AdminFeatureFlags(),
  );
}
