import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current.path;
  final docsFile = File('$root/docs/generated/cms_bundled_content_export.json');
  final adminFile = File(
    '$root/apps/admin/data/cms_bundled_content_export.json',
  );

  final problems = <String>[];

  if (!docsFile.existsSync()) {
    problems.add('Missing docs/generated/cms_bundled_content_export.json');
  }
  if (!adminFile.existsSync()) {
    problems.add('Missing apps/admin/data/cms_bundled_content_export.json');
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

  const forbiddenPublicPhrases = [
    'beta access active',
    'demo data',
    'for codex',
    'do not show',
    'internal note',
    'pro feature',
  ];
  final docsText = docsFile.readAsStringSync().toLowerCase();
  for (final phrase in forbiddenPublicPhrases) {
    if (docsText.contains(phrase)) {
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
