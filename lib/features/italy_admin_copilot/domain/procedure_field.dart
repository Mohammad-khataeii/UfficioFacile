enum ProcedureFieldType {
  text,
  textarea,
  select,
  multiselect,
  date,
  boolean,
  email,
  phone,
  number,
}

ProcedureFieldType procedureFieldTypeFromJson(String? value) {
  return ProcedureFieldType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ProcedureFieldType.text,
  );
}

class FieldOption {
  const FieldOption({
    required this.value,
    required this.label,
    this.description,
  });

  final String value;
  final String label;
  final String? description;

  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    'description': description,
  };

  factory FieldOption.fromJson(Map<String, dynamic> json) => FieldOption(
    value: json['value'] as String? ?? '',
    label: json['label'] as String? ?? '',
    description: json['description'] as String?,
  );
}

class FieldCondition {
  const FieldCondition({
    required this.fieldId,
    required this.operator,
    this.value,
  });

  final String fieldId;
  final String operator;
  final dynamic value;

  bool evaluate(Map<String, dynamic> input) {
    final current = input[fieldId];
    switch (operator) {
      case 'equals':
        return current == value;
      case 'notEquals':
        return current != value;
      case 'contains':
        return current is List && current.contains(value);
      case 'isTrue':
        return current == true;
      case 'isFalse':
        return current == false;
      case 'hasValue':
        if (current is String) {
          return current.trim().isNotEmpty;
        }
        return current != null;
      default:
        return true;
    }
  }

  Map<String, dynamic> toJson() => {
    'fieldId': fieldId,
    'operator': operator,
    'value': value,
  };

  factory FieldCondition.fromJson(Map<String, dynamic> json) => FieldCondition(
    fieldId: json['fieldId'] as String? ?? '',
    operator: json['operator'] as String? ?? 'equals',
    value: json['value'],
  );
}

class FieldValidation {
  const FieldValidation({
    this.minLength,
    this.maxLength,
    this.regex,
    this.errorMessage,
  });

  final int? minLength;
  final int? maxLength;
  final String? regex;
  final String? errorMessage;

  Map<String, dynamic> toJson() => {
    'minLength': minLength,
    'maxLength': maxLength,
    'regex': regex,
    'errorMessage': errorMessage,
  };

  factory FieldValidation.fromJson(Map<String, dynamic> json) =>
      FieldValidation(
        minLength: json['minLength'] as int?,
        maxLength: json['maxLength'] as int?,
        regex: json['regex'] as String?,
        errorMessage: json['errorMessage'] as String?,
      );
}

class ProcedureField {
  const ProcedureField({
    required this.id,
    required this.label,
    required this.type,
    this.placeholder,
    this.helpText,
    required this.required,
    this.options = const [],
    this.defaultValue,
    this.section,
    this.showWhen,
    this.validation,
  });

  final String id;
  final String label;
  final ProcedureFieldType type;
  final String? placeholder;
  final String? helpText;
  final bool required;
  final List<FieldOption> options;
  final dynamic defaultValue;
  final String? section;
  final FieldCondition? showWhen;
  final FieldValidation? validation;

  bool isVisible(Map<String, dynamic> input) {
    return showWhen?.evaluate(input) ?? true;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'type': type.name,
    'placeholder': placeholder,
    'helpText': helpText,
    'required': required,
    'options': options.map((item) => item.toJson()).toList(),
    'defaultValue': defaultValue,
    'section': section,
    'showWhen': showWhen?.toJson(),
    'validation': validation?.toJson(),
  };

  factory ProcedureField.fromJson(Map<String, dynamic> json) => ProcedureField(
    id: json['id'] as String? ?? '',
    label: json['label'] as String? ?? '',
    type: procedureFieldTypeFromJson(json['type'] as String?),
    placeholder: json['placeholder'] as String?,
    helpText: json['helpText'] as String?,
    required: json['required'] as bool? ?? false,
    options: ((json['options'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => FieldOption.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    defaultValue: json['defaultValue'],
    section: json['section'] as String?,
    showWhen: json['showWhen'] is Map
        ? FieldCondition.fromJson(
            Map<String, dynamic>.from(json['showWhen'] as Map),
          )
        : null,
    validation: json['validation'] is Map
        ? FieldValidation.fromJson(
            Map<String, dynamic>.from(json['validation'] as Map),
          )
        : null,
  );
}
