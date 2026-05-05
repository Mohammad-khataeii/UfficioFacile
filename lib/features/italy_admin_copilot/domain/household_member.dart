enum HouseholdRelationship {
  self,
  spouse,
  partner,
  child,
  roommate,
  client,
  other,
}

HouseholdRelationship householdRelationshipFromJson(String? value) {
  return HouseholdRelationship.values.firstWhere(
    (item) => item.name == value,
    orElse: () => HouseholdRelationship.other,
  );
}

class HouseholdMember {
  const HouseholdMember({
    required this.id,
    required this.displayName,
    required this.relationship,
    this.fullName,
    this.codiceFiscale,
    this.dateOfBirth,
    this.email,
    this.phone,
    this.nationality,
    this.notes,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final HouseholdRelationship relationship;
  final String? fullName;
  final String? codiceFiscale;
  final DateTime? dateOfBirth;
  final String? email;
  final String? phone;
  final String? nationality;
  final String? notes;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'relationship': relationship.name,
    'fullName': fullName,
    'codiceFiscale': codiceFiscale,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'email': email,
    'phone': phone,
    'nationality': nationality,
    'notes': notes,
    'isPrimary': isPrimary,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory HouseholdMember.fromJson(
    Map<String, dynamic> json,
  ) => HouseholdMember(
    id: json['id'] as String? ?? '',
    displayName: json['displayName'] as String? ?? '',
    relationship: householdRelationshipFromJson(
      json['relationship'] as String?,
    ),
    fullName: json['fullName'] as String?,
    codiceFiscale: json['codiceFiscale'] as String?,
    dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? ''),
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    nationality: json['nationality'] as String?,
    notes: json['notes'] as String?,
    isPrimary: json['isPrimary'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
