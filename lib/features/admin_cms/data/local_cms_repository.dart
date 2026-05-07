import '../domain/cms_models.dart';
import 'cms_repository.dart';

class LocalCmsRepository implements CmsRepository {
  const LocalCmsRepository();

  @override
  Future<void> addRevision({
    required String entityType,
    String? entityId,
    String? entitySlug,
    required String action,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
  }) async {}

  @override
  Future<List<CmsContentBlock>> listBlocks(String procedureSlug) async =>
      const [];

  @override
  Future<List<CmsCategory>> listCategories() async => const [];

  @override
  Future<List<CmsProcedure>> listProcedures({String? categorySlug}) async =>
      const [];

  @override
  Future<void> saveBlock(Map<String, dynamic> values) async {}

  @override
  Future<void> saveCategory(Map<String, dynamic> values) async {}

  @override
  Future<void> saveDraft({
    required String entityType,
    required String entitySlug,
    required Map<String, dynamic> draftValue,
    required String status,
  }) async {}

  @override
  Future<void> saveProcedure(Map<String, dynamic> values) async {}
}
