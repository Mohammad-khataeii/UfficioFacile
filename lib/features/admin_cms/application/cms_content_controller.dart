import 'package:flutter/foundation.dart';

import '../data/bundled_to_cms_mapper.dart';
import '../data/cms_repository.dart';
import '../domain/cms_models.dart';

class CmsContentController extends ChangeNotifier {
  CmsContentController(this._repository);

  final CmsRepository _repository;
  final BundledToCmsMapper _mapper = const BundledToCmsMapper();

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
    } catch (error) {
      errorMessage = '$error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importBundledContent({bool publish = true}) async {
    for (final category in _mapper.exportCategories()) {
      await _repository.saveCategory(category);
      await _repository.addRevision(
        entityType: 'category',
        entitySlug: category['slug'] as String?,
        action: 'import',
        afterValue: category,
      );
    }
    for (final procedure in _mapper.exportProcedures()) {
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
