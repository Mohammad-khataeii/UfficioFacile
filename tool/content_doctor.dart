import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current.path;
  final docsFile = File('$root/docs/generated/cms_bundled_content_export.json');
  final adminFile = File(
    '$root/apps/admin/data/cms_bundled_content_export.json',
  );
  final migrationsDir = Directory('$root/supabase/migrations');

  final problems = <String>[];

  if (!docsFile.existsSync()) {
    problems.add('Missing docs/generated/cms_bundled_content_export.json');
  }
  if (!adminFile.existsSync()) {
    problems.add('Missing apps/admin/data/cms_bundled_content_export.json');
  }
  if (!migrationsDir.existsSync()) {
    problems.add('Missing supabase/migrations directory');
  }

  if (problems.isNotEmpty) {
    stderr.writeln('Content doctor failed:');
    for (final problem in problems) {
      stderr.writeln('- $problem');
    }
    exitCode = 1;
    return;
  }

  final docsJson =
      jsonDecode(docsFile.readAsStringSync()) as Map<String, dynamic>;
  final adminJson =
      jsonDecode(adminFile.readAsStringSync()) as Map<String, dynamic>;

  final docsCategories =
      (docsJson['cmsCategories'] as List<dynamic>? ?? const []).cast<Map>();
  final adminCategories =
      (adminJson['cmsCategories'] as List<dynamic>? ?? const []).cast<Map>();
  final docsTree = (docsJson['categories'] as List<dynamic>? ?? const [])
      .cast<Map>();
  final adminTree = (adminJson['categories'] as List<dynamic>? ?? const [])
      .cast<Map>();
  final docsProcedures =
      (docsJson['cmsProcedures'] as List<dynamic>? ?? const []).cast<Map>();
  final adminProcedures =
      (adminJson['cmsProcedures'] as List<dynamic>? ?? const []).cast<Map>();
  final migrationFiles = migrationsDir
      .listSync()
      .whereType<File>()
      .map((file) => file.path.split(Platform.pathSeparator).last)
      .toList();

  final docsSlugs = docsCategories.map((row) => '${row['slug']}').toSet();
  final adminSlugs = adminCategories.map((row) => '${row['slug']}').toSet();
  final docsTreeSlugs = docsTree.map((row) => '${row['slug']}').toSet();
  final adminTreeSlugs = adminTree.map((row) => '${row['slug']}').toSet();

  const requiredCategories = <String>{
    'health_asl',
    'housing_rent',
    'utilities_electricity_gas',
    'canone_rai',
    'telecom_internet_mobile',
    'public_office_comune',
    'work_inps_patronato',
    'university_student',
    'general',
    'bonuses-benefits',
    'loans-credit',
  };

  for (final slug in requiredCategories) {
    if (!docsTreeSlugs.contains(slug)) {
      problems.add('Docs canonical tree is missing category `$slug`');
    }
    if (!adminTreeSlugs.contains(slug)) {
      problems.add('Admin canonical tree is missing category `$slug`');
    }
    if (!docsSlugs.contains(slug)) {
      problems.add('Docs export is missing category `$slug`');
    }
    if (!adminSlugs.contains(slug)) {
      problems.add('Admin export is missing category `$slug`');
    }
  }

  if (docsCategories.length != adminCategories.length) {
    problems.add(
      'Category count mismatch: docs=${docsCategories.length}, admin=${adminCategories.length}',
    );
  }
  if (docsProcedures.length != adminProcedures.length) {
    problems.add(
      'Procedure count mismatch: docs=${docsProcedures.length}, admin=${adminProcedures.length}',
    );
  }

  if (docsTree.length != 11 || adminTree.length != 11) {
    problems.add(
      'Canonical category tree count must be 11: docs=${docsTree.length}, admin=${adminTree.length}',
    );
  }

  if (docsJson['cmsContentBlocks'] is! List ||
      adminJson['cmsContentBlocks'] is! List) {
    problems.add('Canonical export must contain cmsContentBlocks arrays');
  }

  final hasPremiumRuntimeMigration = migrationFiles.any(
    (name) =>
        name.contains('harden_premium_plan_tables') ||
        name.contains('fix_premium_profile_runtime_schema'),
  );
  if (!hasPremiumRuntimeMigration) {
    problems.add(
      'Missing premium runtime migration for plan products and entitlements',
    );
  }
  final hasProfileRuntimeMigration = migrationFiles.any(
    (name) => name.contains('fix_premium_profile_runtime_schema'),
  );
  if (!hasProfileRuntimeMigration) {
    problems.add('Missing canonical profile runtime migration');
  }

  final duplicateCategorySlugs = <String>{};
  final seenCategorySlugs = <String>{};
  for (final row in docsCategories) {
    final slug = '${row['slug']}';
    if (!seenCategorySlugs.add(slug)) {
      duplicateCategorySlugs.add(slug);
    }
  }
  if (duplicateCategorySlugs.isNotEmpty) {
    problems.add(
      'Duplicate category slugs found: ${duplicateCategorySlugs.toList()..sort()}',
    );
  }

  if (docsFile.lengthSync() == 0 || adminFile.lengthSync() == 0) {
    problems.add('Generated CMS export files must not be empty');
  }
  if (docsCategories.isEmpty || docsProcedures.isEmpty) {
    problems.add(
      'Generated CMS exports must include non-empty cmsCategories and cmsProcedures',
    );
  }

  final duplicateProcedureKeys = <String, int>{};
  final duplicateRoutes = <String, int>{};
  for (final row in docsProcedures) {
    final categorySlug = '${row['category_slug']}'.trim();
    final slug = '${row['slug']}'.trim();
    if (categorySlug.isEmpty || slug.isEmpty) {
      problems.add(
        'Procedure is missing category_slug or slug: ${jsonEncode({'category_slug': row['category_slug'], 'slug': row['slug'], 'id': row['id']})}',
      );
      continue;
    }
    final key = '$categorySlug::$slug';
    duplicateProcedureKeys[key] = (duplicateProcedureKeys[key] ?? 0) + 1;
    final route = '/content/procedures/$categorySlug/$slug';
    duplicateRoutes[route] = (duplicateRoutes[route] ?? 0) + 1;
  }
  final duplicateProcedureEntries =
      duplicateProcedureKeys.entries
          .where((entry) => entry.value > 1)
          .map((entry) => '${entry.key} (${entry.value})')
          .toList()
        ..sort();
  if (duplicateProcedureEntries.isNotEmpty) {
    problems.add(
      'Duplicate procedure public identities found: $duplicateProcedureEntries',
    );
  }
  final duplicateRouteEntries =
      duplicateRoutes.entries
          .where((entry) => entry.value > 1)
          .map((entry) => '${entry.key} (${entry.value})')
          .toList()
        ..sort();
  if (duplicateRouteEntries.isNotEmpty) {
    problems.add(
      'Duplicate public procedure routes found: $duplicateRouteEntries',
    );
  }

  const requiredLanguages = ['en', 'it', 'fr', 'es', 'fa', 'ar'];
  for (final row in docsCategories) {
    final title = row['title'];
    if (title is! Map) {
      problems.add('Category `${row['slug']}` is missing localized title map');
      continue;
    }
    for (final language in requiredLanguages) {
      final value = title[language]?.toString().trim() ?? '';
      if (value.isEmpty) {
        problems.add(
          'Category `${row['slug']}` is missing title for `$language`',
        );
      }
    }
  }

  for (final row in docsProcedures) {
    final title = row['title'];
    if (title is! Map) {
      problems.add(
        'Procedure `${row['category_slug']}::${row['slug']}` is missing localized title map',
      );
      continue;
    }
    for (final language in requiredLanguages) {
      final value = title[language]?.toString().trim() ?? '';
      if (value.isEmpty) {
        problems.add(
          'Procedure `${row['category_slug']}::${row['slug']}` is missing title for `$language`',
        );
      }
    }
  }

  final procedureBySlug = <String, Map>{};
  for (final row in docsProcedures) {
    procedureBySlug['${row['category_slug']}::${row['slug']}'] = row;
  }

  Map? findProcedureByCanonicalSubcategory(
    String categorySlug,
    String canonicalSubcategoryId,
  ) {
    for (final row in docsProcedures) {
      if ('${row['category_slug']}' != categorySlug) continue;
      final metadata = row['metadata'];
      if (metadata is Map &&
          metadata['canonical_subcategory_id'] == canonicalSubcategoryId) {
        return row;
      }
    }
    return null;
  }

  void expectInteractiveToolByCanonicalSubcategory(
    String categorySlug,
    String canonicalSubcategoryId,
    String toolType,
  ) {
    final row = findProcedureByCanonicalSubcategory(
      categorySlug,
      canonicalSubcategoryId,
    );
    if (row == null) {
      problems.add(
        'Missing interactive procedure for `$categorySlug::$canonicalSubcategoryId`',
      );
      return;
    }
    final metadata = row['metadata'];
    if (metadata is! Map || metadata['tool_type'] != toolType) {
      problems.add(
        'Procedure `${row['category_slug']}::${row['slug']}` must declare tool_type `$toolType`',
      );
    }
  }

  expectInteractiveToolByCanonicalSubcategory(
    'bonuses-benefits',
    'bonus_finder',
    'bonus_finder',
  );
  expectInteractiveToolByCanonicalSubcategory(
    'loans-credit',
    'compare_loans_safely',
    'loan_comparison',
  );

  const forbiddenPublicPhrases = [
    'to help the user',
    'the user should',
    'beta access active',
    'demo data',
    'for codex',
    'do not show',
    'internal note',
    'pro feature',
    'lorem',
    'placeholder',
    'todo',
    'fixme',
  ];
  final docsText = docsFile.readAsStringSync().toLowerCase();
  for (final phrase in forbiddenPublicPhrases) {
    if (_forbiddenPattern(phrase).hasMatch(docsText)) {
      problems.add(
        'Public bundled export still contains forbidden phrase `$phrase`',
      );
    }
  }

  for (final row in docsCategories) {
    final slug = '${row['slug']}';
    if (slug == 'bonuses-benefits' || slug == 'loans-credit') {
      if (row['is_premium'] != true) {
        problems.add('Money category `$slug` must be premium');
      }
      if ((row['premium_teaser'] as Map?) == null) {
        problems.add('Money category `$slug` is missing premium teaser');
      }
    }
  }

  for (final row in docsProcedures) {
    final lower = jsonEncode(row).toLowerCase();
    final metadata = row['metadata'];
    if (lower.contains('answer a few questions') &&
        (metadata is! Map || metadata['tool_type'] == null)) {
      problems.add(
        'Procedure `${row['category_slug']}::${row['slug']}` describes an interactive questionnaire without tool_type metadata',
      );
    }
    if (row['is_premium'] == true) {
      final teaser = row['premium_teaser'];
      if (teaser is! Map || teaser.isEmpty) {
        problems.add(
          'Premium procedure `${row['category_slug']}::${row['slug']}` is missing premium teaser',
        );
      }
    }
  }

  if (problems.isNotEmpty) {
    stderr.writeln('Content doctor failed:');
    for (final problem in problems) {
      stderr.writeln('- $problem');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Content doctor passed.');
  stdout.writeln('Categories: ${docsCategories.length}');
  stdout.writeln('Procedures: ${docsProcedures.length}');
  stdout.writeln(
    'Verified required categories: ${requiredCategories.toList()..sort()}',
  );
}

RegExp _forbiddenPattern(String phrase) {
  if (const {'todo', 'fixme', 'lorem', 'placeholder'}.contains(phrase)) {
    return RegExp('\\b${RegExp.escape(phrase)}\\b', caseSensitive: false);
  }
  return RegExp(RegExp.escape(phrase), caseSensitive: false);
}
