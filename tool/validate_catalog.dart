import 'dart:convert';
import 'dart:io';

void main() {
  final problems = <String>[];
  final root = Directory.current;
  final catalogDirectory = Directory('${root.path}/assets/catalog');
  final pubspecFile = File('${root.path}/pubspec.yaml');

  if (!catalogDirectory.existsSync()) {
    problems.add('Missing assets/catalog directory');
  }
  if (!pubspecFile.existsSync()) {
    problems.add('Missing pubspec.yaml');
  }
  if (problems.isNotEmpty) {
    _fail(problems);
  }

  final pubspecText = pubspecFile.readAsStringSync();
  if (!pubspecText.contains('assets/catalog/') &&
      !pubspecText.contains('assets/catalog/ufficio_catalog.')) {
    problems.add('pubspec.yaml does not declare assets/catalog assets');
  }
  final catalogFiles =
      catalogDirectory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (catalogFiles.isEmpty) {
    problems.add('No catalog JSON files found in assets/catalog');
    _fail(problems);
  }

  const forbiddenPhrases = <String>[
    'to help the user',
    'the user should',
    'internal note',
    'placeholder',
    'todo',
    'fake data',
    'lorem ipsum',
    'do not route',
    'do not tell',
  ];

  var totalCategories = 0;
  var totalSubcategories = 0;

  for (final catalogFile in catalogFiles) {
    final relativePath = catalogFile.path.replaceFirst('${root.path}/', '');
    late final Map<String, dynamic> catalog;
    try {
      catalog =
          jsonDecode(catalogFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (error) {
      problems.add('$relativePath is invalid JSON: $error');
      continue;
    }

    if (catalog['version'] == null) {
      problems.add('$relativePath is missing version');
    }
    final categories =
        (catalog['categories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    if (categories.isEmpty) {
      problems.add('$relativePath has no categories');
      continue;
    }

    final categoryIds = <String>{};
    final duplicateCategoryIds = <String>{};
    var subcategoryCount = 0;
    for (final category in categories) {
      totalCategories++;
      final categoryId = '${category['id'] ?? ''}';
      if (categoryId.isEmpty) {
        problems.add('$relativePath has a category with empty id');
        continue;
      }
      if (!categoryIds.add(categoryId)) {
        duplicateCategoryIds.add(categoryId);
      }
      _checkLocalizedField(
        problems,
        '$relativePath::$categoryId',
        'title',
        category['title'],
      );
      _checkLocalizedField(
        problems,
        '$relativePath::$categoryId',
        'description',
        category['description'],
      );

      final subcategories =
          (category['subcategories'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
      if (subcategories.isEmpty) {
        problems.add('$relativePath::$categoryId has no subcategories');
      }
      final subcategoryIds = <String>{};
      for (final subcategory in subcategories) {
        totalSubcategories++;
        subcategoryCount++;
        final subcategoryId = '${subcategory['id'] ?? ''}';
        if (subcategoryId.isEmpty) {
          problems.add(
            '$relativePath::$categoryId has subcategory with empty id',
          );
          continue;
        }
        if (!subcategoryIds.add(subcategoryId)) {
          problems.add(
            '$relativePath::$categoryId contains duplicate subcategory `$subcategoryId`',
          );
        }
        _checkLocalizedField(
          problems,
          '$relativePath::$categoryId::$subcategoryId',
          'title',
          subcategory['title'],
        );
        _checkLocalizedField(
          problems,
          '$relativePath::$categoryId::$subcategoryId',
          'description',
          subcategory['description'],
        );

        final procedures =
            (subcategory['procedures'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
        final procedureIds = <String>{};
        for (final procedure in procedures) {
          final procedureId = '${procedure['id'] ?? ''}';
          if (procedureId.isEmpty) {
            problems.add(
              '$relativePath::$categoryId::$subcategoryId has procedure with empty id',
            );
            continue;
          }
          if (!procedureIds.add(procedureId)) {
            problems.add(
              '$relativePath::$categoryId::$subcategoryId has duplicate procedure `$procedureId`',
            );
          }
          _checkLocalizedField(
            problems,
            '$relativePath::$categoryId::$subcategoryId::$procedureId',
            'title',
            procedure['title'],
          );
        }
      }
    }

    if (duplicateCategoryIds.isNotEmpty) {
      final sortedDuplicateCategoryIds = duplicateCategoryIds.toList()..sort();
      problems.add(
        '$relativePath has duplicate category ids: $sortedDuplicateCategoryIds',
      );
    }

    if (subcategoryCount == 0) {
      problems.add('$relativePath has no subcategories at all');
    }

    final health = categories.cast<Map<String, dynamic>?>().firstWhere(
      (category) => category?['id'] == 'health_asl',
      orElse: () => null,
    );
    if (health == null) {
      problems.add('$relativePath is missing health_asl category');
    } else {
      final healthSubcategories =
          (health['subcategories'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
      if (healthSubcategories.isEmpty) {
        problems.add('$relativePath health_asl has no subcategories');
      }
      if (relativePath.contains('torino')) {
        final subcategoryIds = healthSubcategories
            .map((item) => '${item['id'] ?? ''}')
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
            problems.add(
              '$relativePath health_asl is missing required subcategory `$required`',
            );
          }
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
        problems.add(
          '$relativePath contains forbidden public phrase `$phrase`',
        );
      }
    }
  }

  if (problems.isNotEmpty) {
    _fail(problems);
  }

  stdout.writeln('Catalog validation passed.');
  stdout.writeln('Catalog files: ${catalogFiles.length}');
  stdout.writeln('Categories: $totalCategories');
  stdout.writeln('Subcategories: $totalSubcategories');
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
