enum ProofCaseStatus { open, sent, waiting, resolved, archived }

enum ProofItemType {
  photo,
  bill,
  contract,
  receipt,
  screenshot,
  email,
  pecReceipt,
  protocolNumber,
  chatMessage,
  other,
}

ProofCaseStatus proofCaseStatusFromJson(String? value) {
  return ProofCaseStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ProofCaseStatus.open,
  );
}

ProofItemType proofItemTypeFromJson(String? value) {
  return ProofItemType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ProofItemType.other,
  );
}

class ProofCase {
  const ProofCase({
    required this.id,
    required this.title,
    required this.category,
    this.relatedRequestId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String title;
  final String category;
  final String? relatedRequestId;
  final ProofCaseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'relatedRequestId': relatedRequestId,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'notes': notes,
  };

  factory ProofCase.fromJson(Map<String, dynamic> json) => ProofCase(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    category: json['category'] as String? ?? '',
    relatedRequestId: json['relatedRequestId'] as String?,
    status: proofCaseStatusFromJson(json['status'] as String?),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    notes: json['notes'] as String?,
  );
}

class ProofItem {
  const ProofItem({
    required this.id,
    required this.caseId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.fileName,
    this.localFilePath,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String caseId;
  final ProofItemType type;
  final String title;
  final String description;
  final DateTime date;
  final String? fileName;
  final String? localFilePath;
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'caseId': caseId,
    'type': type.name,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'fileName': fileName,
    'localFilePath': localFilePath,
    'referenceNumber': referenceNumber,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ProofItem.fromJson(Map<String, dynamic> json) => ProofItem(
    id: json['id'] as String? ?? '',
    caseId: json['caseId'] as String? ?? '',
    type: proofItemTypeFromJson(json['type'] as String?),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    fileName: json['fileName'] as String?,
    localFilePath: json['localFilePath'] as String?,
    referenceNumber: json['referenceNumber'] as String?,
    notes: json['notes'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
