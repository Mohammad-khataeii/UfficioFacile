import 'dart:convert';
import 'dart:io';

void main() {
  final problems = <String>[];
  final root = Directory.current;
  final catalogFile = File(
    '${root.path}/assets/catalog/ufficio_catalog.v1.json',
  );
  final pubspecFile = File('${root.path}/pubspec.yaml');

  if (!catalogFile.existsSync()) {
    problems.add('Missing assets/catalog/ufficio_catalog.v1.json');
  }
  if (!pubspecFile.existsSync()) {
    problems.add('Missing pubspec.yaml');
  }
  if (problems.isNotEmpty) {
    _fail(problems);
  }

  final pubspecText = pubspecFile.readAsStringSync();
  if (!pubspecText.contains('assets/catalog/') &&
      !pubspecText.contains('assets/catalog/ufficio_catalog.v1.json')) {
    problems.add(
      'pubspec.yaml does not declare assets/catalog/ufficio_catalog.v1.json',
    );
  }

  late final Map<String, dynamic> catalog;
  try {
    catalog =
        jsonDecode(catalogFile.readAsStringSync()) as Map<String, dynamic>;
  } catch (error) {
    problems.add('Catalog JSON is invalid: $error');
    _fail(problems);
  }

  if (catalog['version'] == null) {
    problems.add('Catalog is missing version');
  }
  final categories =
      (catalog['categories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
  if (categories.isEmpty) {
    problems.add('Catalog categories are empty');
  }

  const forbiddenPhrases = <String>[
    'to help the user',
    'the user should',
    'do not show',
    'internal',
    'placeholder',
    'todo',
    'fake data',
    'lorem ipsum',
    'do not route',
    'do not tell',
  ];

  final categoryIds = <String>{};
  final duplicateCategoryIds = <String>{};
  var subcategoryCount = 0;
  var singleProcedureSubcategoryCount = 0;

  for (final category in categories) {
    final categoryId = '${category['id'] ?? ''}';
    if (categoryId.isEmpty) {
      problems.add('Found category with empty id');
      continue;
    }
    if (!categoryIds.add(categoryId)) {
      duplicateCategoryIds.add(categoryId);
    }
    _checkLocalizedField(problems, categoryId, 'title', category['title']);
    _checkLocalizedField(
      problems,
      categoryId,
      'description',
      category['description'],
    );

    final subcategories =
        (category['subcategories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    if (subcategories.isEmpty) {
      problems.add('Category `$categoryId` has no subcategories');
    }
    final subcategoryIds = <String>{};
    for (final subcategory in subcategories) {
      subcategoryCount++;
      final subcategoryId = '${subcategory['id'] ?? ''}';
      if (subcategoryId.isEmpty) {
        problems.add('Category `$categoryId` has subcategory with empty id');
        continue;
      }
      if (!subcategoryIds.add(subcategoryId)) {
        problems.add(
          'Category `$categoryId` contains duplicate subcategory `$subcategoryId`',
        );
      }
      _checkLocalizedField(
        problems,
        '$categoryId::$subcategoryId',
        'title',
        subcategory['title'],
      );
      _checkLocalizedField(
        problems,
        '$categoryId::$subcategoryId',
        'description',
        subcategory['description'],
      );

      final procedures =
          (subcategory['procedures'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
      if (procedures.length == 1) {
        singleProcedureSubcategoryCount++;
      }
      final procedureIds = <String>{};
      for (final procedure in procedures) {
        final procedureId = '${procedure['id'] ?? ''}';
        if (procedureId.isEmpty) {
          problems.add(
            'Subcategory `$categoryId::$subcategoryId` has procedure with empty id',
          );
          continue;
        }
        if (!procedureIds.add(procedureId)) {
          problems.add(
            'Subcategory `$categoryId::$subcategoryId` has duplicate procedure `$procedureId`',
          );
        }
        _checkLocalizedField(
          problems,
          '$categoryId::$subcategoryId::$procedureId',
          'title',
          procedure['title'],
        );
      }
    }
  }

  if (duplicateCategoryIds.isNotEmpty) {
    final sortedDuplicateCategoryIds = duplicateCategoryIds.toList()..sort();
    problems.add('Duplicate category ids: $sortedDuplicateCategoryIds');
  }

  if (subcategoryCount > 0 &&
      singleProcedureSubcategoryCount / subcategoryCount > 0.70) {
    problems.add(
      'Catalog still looks flattened: $singleProcedureSubcategoryCount of '
      '$subcategoryCount subcategories contain exactly one procedure.',
    );
  }

  final health = categories.cast<Map<String, dynamic>?>().firstWhere(
    (category) => category?['id'] == 'health_asl',
    orElse: () => null,
  );
  if (health == null) {
    problems.add('Missing canonical health_asl category');
  } else {
    final subcategoryIds =
        ((health['subcategories'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map>()
                .map((item) => '${item['id'] ?? ''}'))
            .toSet();
    const requiredHealthSubcategories = <String>{
      'ssn_asl_access',
      'doctor_health_card',
      'bookings_prescriptions_cup',
      'ticket_exemptions',
      'digital_health_record',
      'asl_problems',
      'student_insurance',
    };
    for (final required in requiredHealthSubcategories) {
      if (!subcategoryIds.contains(required)) {
        problems.add('health_asl is missing required subcategory `$required`');
      }
    }
  }

  final rawText = catalogFile.readAsStringSync().toLowerCase();
  for (final phrase in forbiddenPhrases) {
    final escaped = RegExp.escape(phrase);
    final pattern = RegExp(
      r'(?<![a-z0-9_])' + escaped + r'(?![a-z0-9_])',
      caseSensitive: false,
    );
    if (pattern.hasMatch(rawText)) {
      problems.add('Catalog contains forbidden public phrase `$phrase`');
    }
  }

  if (problems.isNotEmpty) {
    _fail(problems);
  }

  stdout.writeln('Catalog validation passed.');
  stdout.writeln('Categories: ${categories.length}');
  stdout.writeln('Subcategories: $subcategoryCount');
}

void _checkLocalizedField(
  List<String> problems,
  String id,
  String field,
  dynamic value,
) {
  if (value is! Map) {
    problems.add('$id is missing localized $field map');
    return;
  }

  const requiredLanguages = ['en', 'it'];
  const optionalLanguages = ['fr', 'es', 'fa', 'ar'];

  for (final language in requiredLanguages) {
    final text = value[language]?.toString().trim() ?? '';
    if (text.isEmpty) {
      problems.add('$id is missing $field for `$language`');
    }
  }

  for (final language in optionalLanguages) {
    if (!value.containsKey(language)) {
      continue;
    }
    final text = value[language]?.toString().trim() ?? '';
    if (text.isEmpty) {
      problems.add('$id has empty $field for optional language `$language`');
    }
  }
}

Never _fail(List<String> problems) {
  stderr.writeln('Catalog validation failed:');
  for (final problem in problems) {
    stderr.writeln('- $problem');
  }
  exitCode = 1;
  throw StateError('Catalog validation failed');
}
