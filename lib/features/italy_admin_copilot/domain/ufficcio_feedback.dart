class UfficcioFeedback {
  const UfficcioFeedback({
    this.id,
    this.userId,
    this.category,
    required this.message,
    this.rating,
    this.relatedProcedureId,
    this.contactEmail,
    this.status = 'new',
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? userId;
  final String? category;
  final String message;
  final int? rating;
  final String? relatedProcedureId;
  final String? contactEmail;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'category': category,
    'message': message,
    'rating': rating,
    'relatedProcedureId': relatedProcedureId,
    'contactEmail': contactEmail,
    'status': status,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory UfficcioFeedback.fromJson(Map<String, dynamic> json) {
    return UfficcioFeedback(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      category: json['category'] as String?,
      message: json['message'] as String? ?? '',
      rating: json['rating'] as int?,
      relatedProcedureId: json['relatedProcedureId'] as String?,
      contactEmail: json['contactEmail'] as String?,
      status: json['status'] as String? ?? 'new',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
