class UfficcioUserSettings {
  const UfficcioUserSettings({
    this.id,
    this.userId,
    this.selectedLanguage = 'en',
    this.onboardingCompleted = false,
    this.syncEnabled = false,
    this.analyticsEnabled = true,
    this.betaModeEnabled = true,
    this.adminDebugEnabled = false,
    this.paywallEnabled = false,
    this.themeMode = 'system',
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? userId;
  final String selectedLanguage;
  final bool onboardingCompleted;
  final bool syncEnabled;
  final bool analyticsEnabled;
  final bool betaModeEnabled;
  final bool adminDebugEnabled;
  final bool paywallEnabled;
  final String themeMode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UfficcioUserSettings copyWith({
    String? id,
    String? userId,
    String? selectedLanguage,
    bool? onboardingCompleted,
    bool? syncEnabled,
    bool? analyticsEnabled,
    bool? betaModeEnabled,
    bool? adminDebugEnabled,
    bool? paywallEnabled,
    String? themeMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UfficcioUserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      betaModeEnabled: betaModeEnabled ?? this.betaModeEnabled,
      adminDebugEnabled: adminDebugEnabled ?? this.adminDebugEnabled,
      paywallEnabled: paywallEnabled ?? this.paywallEnabled,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'selectedLanguage': selectedLanguage,
    'onboardingCompleted': onboardingCompleted,
    'syncEnabled': syncEnabled,
    'analyticsEnabled': analyticsEnabled,
    'betaModeEnabled': betaModeEnabled,
    'adminDebugEnabled': adminDebugEnabled,
    'paywallEnabled': paywallEnabled,
    'themeMode': themeMode,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory UfficcioUserSettings.fromJson(Map<String, dynamic> json) {
    return UfficcioUserSettings(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      selectedLanguage: json['selectedLanguage'] as String? ?? 'en',
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      syncEnabled: json['syncEnabled'] as bool? ?? false,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      betaModeEnabled: json['betaModeEnabled'] as bool? ?? true,
      adminDebugEnabled: json['adminDebugEnabled'] as bool? ?? false,
      paywallEnabled: json['paywallEnabled'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
