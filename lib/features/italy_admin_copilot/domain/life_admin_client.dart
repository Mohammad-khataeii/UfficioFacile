class LifeAdminClient {
  const LifeAdminClient({
    required this.id,
    required this.displayName,
    this.fullName,
    this.email,
    this.phone,
    this.city,
    this.preferredLanguage,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? city;
  final String? preferredLanguage;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'city': city,
    'preferredLanguage': preferredLanguage,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LifeAdminClient.fromJson(
    Map<String, dynamic> json,
  ) => LifeAdminClient(
    id: json['id'] as String? ?? '',
    displayName: json['displayName'] as String? ?? '',
    fullName: json['fullName'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    city: json['city'] as String?,
    preferredLanguage: json['preferredLanguage'] as String?,
    notes: json['notes'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
