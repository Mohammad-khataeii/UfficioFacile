import 'dart:convert';
import 'dart:io';

import 'package:ufficiofacile/features/italy_admin_copilot/content/cms_seed_exporter.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/content/ufficio_catalog_exporter.dart';

const _outputPaths = [
  'docs/generated/cms_bundled_content_export.json',
  'apps/admin/data/cms_bundled_content_export.json',
];
const _catalogOutputPath = 'assets/catalog/ufficio_catalog.v1.json';

void main() {
  final bundle = buildCmsSeedBundle(
    externalSeedLoader: (sourcePath, categorySlug) {
      final raw = File(sourcePath).readAsStringSync();
      return loadCategoryFromJsonText(raw, categorySlug);
    },
  );

  final encoded = const JsonEncoder.withIndent('  ').convert(bundle);
  for (final outputPath in _outputPaths) {
    final file = File(outputPath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(encoded);
    stdout.writeln('Wrote $outputPath');
  }

  final catalogBundle = buildUfficioCatalogBundleFromCmsSeed(bundle);
  final catalogFile = File(_catalogOutputPath);
  catalogFile.parent.createSync(recursive: true);
  catalogFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(catalogBundle),
  );
  stdout.writeln('Wrote $_catalogOutputPath');
}
