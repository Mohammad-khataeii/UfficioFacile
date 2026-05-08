import 'package:flutter/foundation.dart';

import '../data/cms_repository.dart';
import '../data/local_cms_repository.dart';
import '../domain/cms_models.dart';

class CmsContentController extends ChangeNotifier {
  CmsContentController(this._repository);

  final CmsRepository _repository;
  final LocalCmsRepository _bundledRepository = const LocalCmsRepository();

  List<CmsCategory> categories = const [];
  List<CmsProcedure> procedures = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load({String? categorySlug}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      categories = await _repository.listCategories();
      procedures = await _repository.listProcedures(categorySlug: categorySlug);
      if (categories.isEmpty) {
        categories = await _bundledRepository.listCategories();
      }
      if (procedures.isEmpty) {
        procedures = await _bundledRepository.listProcedures(
          categorySlug: categorySlug,
        );
      }
    } catch (error) {
      try {
        categories = await _bundledRepository.listCategories();
        procedures = await _bundledRepository.listProcedures(
          categorySlug: categorySlug,
        );
        errorMessage = categories.isEmpty && procedures.isEmpty
            ? '$error'
            : null;
      } catch (_) {
        errorMessage = '$error';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importBundledContent({bool publish = true}) async {
    final bundle = await _bundledRepository.loadCanonicalBundle();
    final categories = (bundle['cmsCategories'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final procedures = (bundle['cmsProcedures'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    for (final category in categories) {
      await _repository.saveCategory(category);
      await _repository.addRevision(
        entityType: 'category',
        entitySlug: category['slug'] as String?,
        action: 'import',
        afterValue: category,
      );
    }
    for (final procedure in procedures) {
      await _repository.saveProcedure(procedure);
      await _repository.addRevision(
        entityType: 'procedure',
        entitySlug: procedure['slug'] as String?,
        action: 'import',
        afterValue: procedure,
      );
      if (!publish) {
        await _repository.saveDraft(
          entityType: 'procedure',
          entitySlug: procedure['slug'] as String,
          draftValue: procedure,
          status: 'draft',
        );
      }
    }
    await load();
  }
}
