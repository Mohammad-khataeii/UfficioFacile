import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cms_models.dart';
import 'cms_repository.dart';

class SupabaseCmsRepository implements CmsRepository {
  SupabaseCmsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CmsCategory>> listCategories() async {
    final rows = await _client
        .from('ufficio_cms_categories')
        .select()
        .order('sort_order');
    return rows
        .map((item) => CmsCategory.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<CmsProcedure>> listProcedures({String? categorySlug}) async {
    dynamic query = _client
        .from('ufficio_cms_procedures')
        .select()
        .order('sort_order');
    if (categorySlug != null && categorySlug.isNotEmpty) {
      query = query.eq('category_slug', categorySlug);
    }
    final rows = await query;
    return rows
        .map((item) => CmsProcedure.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<CmsContentBlock>> listBlocks(String procedureSlug) async {
    final rows = await _client
        .from('ufficio_cms_content_blocks')
        .select()
        .eq('procedure_slug', procedureSlug)
        .order('sort_order');
    return rows
        .map(
          (item) => CmsContentBlock.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<void> saveCategory(Map<String, dynamic> values) async {
    await _client.from('ufficio_cms_categories').upsert(values);
  }

  @override
  Future<void> saveProcedure(Map<String, dynamic> values) async {
    await _client.from('ufficio_cms_procedures').upsert(values);
  }

  @override
  Future<void> saveBlock(Map<String, dynamic> values) async {
    await _client.from('ufficio_cms_content_blocks').upsert(values);
  }

  @override
  Future<void> saveDraft({
    required String entityType,
    required String entitySlug,
    required Map<String, dynamic> draftValue,
    required String status,
  }) async {
    await _client.from('ufficio_cms_drafts').insert({
      'entity_type': entityType,
      'entity_slug': entitySlug,
      'draft_value': draftValue,
      'status': status,
      'actor_user_id': _client.auth.currentUser?.id,
    });
  }

  @override
  Future<void> addRevision({
    required String entityType,
    String? entityId,
    String? entitySlug,
    required String action,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
  }) async {
    await _client.from('ufficio_cms_revisions').insert({
      'entity_type': entityType,
      'entity_id': entityId,
      'entity_slug': entitySlug,
      'action': action,
      'before_value': beforeValue,
      'after_value': afterValue,
      'actor_user_id': _client.auth.currentUser?.id,
    });
  }
}
