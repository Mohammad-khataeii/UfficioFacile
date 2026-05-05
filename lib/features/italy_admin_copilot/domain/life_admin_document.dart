enum LifeAdminDocumentType {
  identityCardPassport,
  codiceFiscale,
  tesseraSanitaria,
  permessoDiSoggiorno,
  rentalContract,
  workContract,
  terminationLetter,
  payslip,
  universityEnrollment,
  isee,
  billElectricity,
  billGas,
  billInternet,
  paymentReceipt,
  previousRequestReceipt,
  protocolNumber,
  medicalCertificate,
  other,
}

LifeAdminDocumentType lifeAdminDocumentTypeFromJson(String? value) {
  return LifeAdminDocumentType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => LifeAdminDocumentType.other,
  );
}

class LifeAdminDocument {
  const LifeAdminDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.hasDocument,
    this.expiryDate,
    this.fileName,
    this.localFilePath,
    this.notes,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final LifeAdminDocumentType type;
  final String title;
  final String description;
  final bool hasDocument;
  final DateTime? expiryDate;
  final String? fileName;
  final String? localFilePath;
  final String? notes;
  final String? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LifeAdminDocument copyWith({
    String? id,
    LifeAdminDocumentType? type,
    String? title,
    String? description,
    bool? hasDocument,
    DateTime? expiryDate,
    String? fileName,
    String? localFilePath,
    String? notes,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LifeAdminDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      hasDocument: hasDocument ?? this.hasDocument,
      expiryDate: expiryDate ?? this.expiryDate,
      fileName: fileName ?? this.fileName,
      localFilePath: localFilePath ?? this.localFilePath,
      notes: notes ?? this.notes,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'hasDocument': hasDocument,
    'expiryDate': expiryDate?.toIso8601String(),
    'fileName': fileName,
    'localFilePath': localFilePath,
    'notes': notes,
    'ownerId': ownerId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LifeAdminDocument.fromJson(
    Map<String, dynamic> json,
  ) => LifeAdminDocument(
    id: json['id'] as String? ?? '',
    type: lifeAdminDocumentTypeFromJson(json['type'] as String?),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    hasDocument: json['hasDocument'] as bool? ?? false,
    expiryDate: DateTime.tryParse(json['expiryDate'] as String? ?? ''),
    fileName: json['fileName'] as String?,
    localFilePath: json['localFilePath'] as String?,
    notes: json['notes'] as String?,
    ownerId: json['ownerId'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
