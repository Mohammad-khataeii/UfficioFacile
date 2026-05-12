import '../domain/cms_models.dart';

abstract class CmsRepository {
  Future<List<CmsCategory>> listCategories();
  Future<List<CmsProcedure>> listProcedures({String? categorySlug});
  Future<List<CmsContentBlock>> listBlocks(String procedureSlug);
  Future<List<CmsContentBlock>> listBlocksByProcedure(
    String categorySlug,
    String procedureSlug,
  );
  Future<void> saveCategory(Map<String, dynamic> values);
  Future<void> saveProcedure(Map<String, dynamic> values);
  Future<void> saveBlock(Map<String, dynamic> values);
  Future<void> saveDraft({
    required String entityType,
    required String entitySlug,
    required Map<String, dynamic> draftValue,
    required String status,
  });
  Future<void> addRevision({
    required String entityType,
    String? entityId,
    String? entitySlug,
    required String action,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
  });
}
