enum LifeAdminContactType {
  asl,
  comune,
  university,
  landlord,
  patronato,
  utilityProvider,
  telecomProvider,
  other,
}

LifeAdminContactType lifeAdminContactTypeFromJson(String? value) {
  return LifeAdminContactType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => LifeAdminContactType.other,
  );
}

class LifeAdminContact {
  const LifeAdminContact({
    required this.id,
    required this.type,
    required this.name,
    this.email,
    this.pec,
    this.phone,
    this.website,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final LifeAdminContactType type;
  final String name;
  final String? email;
  final String? pec;
  final String? phone;
  final String? website;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'email': email,
    'pec': pec,
    'phone': phone,
    'website': website,
    'address': address,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LifeAdminContact.fromJson(
    Map<String, dynamic> json,
  ) => LifeAdminContact(
    id: json['id'] as String? ?? '',
    type: lifeAdminContactTypeFromJson(json['type'] as String?),
    name: json['name'] as String? ?? '',
    email: json['email'] as String?,
    pec: json['pec'] as String?,
    phone: json['phone'] as String?,
    website: json['website'] as String?,
    address: json['address'] as String?,
    notes: json['notes'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
