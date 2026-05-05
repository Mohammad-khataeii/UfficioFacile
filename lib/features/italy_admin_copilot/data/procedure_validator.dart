import '../domain/procedure_field.dart';
import '../domain/admin_procedure.dart';
import '../domain/validation_result.dart';

class ProcedureValidator {
  static ValidationResult validate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    final fieldErrors = <String, String>{};
    final globalErrors = <String>[];

    for (final field in procedure.fields) {
      if (!field.isVisible(inputData)) {
        continue;
      }
      final value = inputData[field.id];
      if (field.required && _isEmpty(value, field.type)) {
        fieldErrors[field.id] = 'This field is required.';
        continue;
      }
      if (_isEmpty(value, field.type)) {
        continue;
      }
      switch (field.type) {
        case ProcedureFieldType.email:
          final email = '$value'.trim();
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
            fieldErrors[field.id] = 'Enter a valid email address.';
          }
        case ProcedureFieldType.phone:
          final phone = '$value'.trim();
          if (phone.length < 6) {
            fieldErrors[field.id] = 'Enter a valid phone number.';
          }
        case ProcedureFieldType.date:
          if (value is! DateTime && DateTime.tryParse('$value') == null) {
            fieldErrors[field.id] = 'Select a valid date.';
          }
        case ProcedureFieldType.select:
          final allowed = field.options.map((item) => item.value).toSet();
          if (!allowed.contains(value)) {
            fieldErrors[field.id] = 'Select one of the available options.';
          }
        case ProcedureFieldType.multiselect:
          final allowed = field.options.map((item) => item.value).toSet();
          final values =
              (value as List?)?.map((item) => '$item').toList() ?? [];
          if (values.any((item) => !allowed.contains(item))) {
            fieldErrors[field.id] = 'Choose valid options only.';
          }
        case ProcedureFieldType.textarea:
          final minLength = field.validation?.minLength ?? 10;
          if ('$value'.trim().length < minLength) {
            fieldErrors[field.id] =
                field.validation?.errorMessage ?? 'Please add more detail.';
          }
        case ProcedureFieldType.number:
          if (num.tryParse('$value') == null) {
            fieldErrors[field.id] = 'Enter a valid number.';
          }
        case ProcedureFieldType.text:
        case ProcedureFieldType.boolean:
      }

      if (field.validation?.regex != null &&
          !RegExp(field.validation!.regex!).hasMatch('$value')) {
        fieldErrors[field.id] =
            field.validation?.errorMessage ?? 'Invalid value.';
      }
    }

    if (fieldErrors.isNotEmpty) {
      globalErrors.add(
        'Please review the highlighted fields before generating.',
      );
    }

    return ValidationResult(
      ok: fieldErrors.isEmpty && globalErrors.isEmpty,
      fieldErrors: fieldErrors,
      globalErrors: globalErrors,
    );
  }

  static bool _isEmpty(dynamic value, ProcedureFieldType type) {
    if (type == ProcedureFieldType.boolean) {
      return value == null;
    }
    if (value == null) {
      return true;
    }
    if (value is String) {
      return value.trim().isEmpty;
    }
    if (value is List) {
      return value.isEmpty;
    }
    return false;
  }
}
