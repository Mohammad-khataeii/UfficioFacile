enum AttachmentCategory {
  identity,
  health,
  housing,
  employment,
  academic,
  financial,
  evidence,
  administrative,
  other,
}

AttachmentCategory attachmentCategoryFromJson(String? value) {
  return AttachmentCategory.values.firstWhere(
    (item) => item.name == value,
    orElse: () => AttachmentCategory.other,
  );
}

class AttachmentSuggestion {
  const AttachmentSuggestion({
    required this.id,
    required this.name,
    required this.description,
    required this.required,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final bool required;
  final AttachmentCategory category;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'required': required,
    'category': category.name,
  };

  factory AttachmentSuggestion.fromJson(Map<String, dynamic> json) =>
      AttachmentSuggestion(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        required: json['required'] as bool? ?? false,
        category: attachmentCategoryFromJson(json['category'] as String?),
      );
}

class AttachmentItem {
  const AttachmentItem({
    required this.id,
    required this.name,
    required this.description,
    required this.required,
    required this.userHasIt,
    this.uploadedFileName,
    this.uploadedFilePath,
  });

  final String id;
  final String name;
  final String description;
  final bool required;
  final bool userHasIt;
  final String? uploadedFileName;
  final String? uploadedFilePath;

  AttachmentItem copyWith({
    String? id,
    String? name,
    String? description,
    bool? required,
    bool? userHasIt,
    String? uploadedFileName,
    String? uploadedFilePath,
  }) {
    return AttachmentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      required: required ?? this.required,
      userHasIt: userHasIt ?? this.userHasIt,
      uploadedFileName: uploadedFileName ?? this.uploadedFileName,
      uploadedFilePath: uploadedFilePath ?? this.uploadedFilePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'required': required,
    'userHasIt': userHasIt,
    'uploadedFileName': uploadedFileName,
    'uploadedFilePath': uploadedFilePath,
  };

  factory AttachmentItem.fromJson(Map<String, dynamic> json) => AttachmentItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    required: json['required'] as bool? ?? false,
    userHasIt: json['userHasIt'] as bool? ?? false,
    uploadedFileName: json['uploadedFileName'] as String?,
    uploadedFilePath: json['uploadedFilePath'] as String?,
  );
}
