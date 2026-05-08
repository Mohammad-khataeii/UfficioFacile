import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cms_models.dart';
import 'cms_repository.dart';
import 'local_cms_repository.dart';

class SupabaseCmsRepository implements CmsRepository {
  SupabaseCmsRepository(this._client);

  final SupabaseClient _client;
  final LocalCmsRepository _fallback = const LocalCmsRepository();
  static const _remoteTimeout = Duration(seconds: 3);

  @override
  Future<List<CmsCategory>> listCategories() async {
    final fallback = await _fallback.listCategories();
    try {
      final rows = await _client
          .from('ufficio_cms_categories')
          .select()
          .order('sort_order')
          .timeout(_remoteTimeout);
      final remote = rows
          .map((item) => CmsCategory.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return _mergeCategories(remote, fallback);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<List<CmsProcedure>> listProcedures({String? categorySlug}) async {
    final fallback = await _fallback.listProcedures(categorySlug: categorySlug);
    try {
      dynamic query = _client
          .from('ufficio_cms_procedures')
          .select()
          .order('sort_order');
      if (categorySlug != null && categorySlug.isNotEmpty) {
        query = query.eq('category_slug', categorySlug);
      }
      final rows = await query.timeout(_remoteTimeout);
      final remote = rows
          .map((item) => CmsProcedure.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return _mergeProcedures(remote, fallback);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<List<CmsContentBlock>> listBlocks(String procedureSlug) async {
    final fallback = await _fallback.listBlocks(procedureSlug);
    try {
      final rows = await _client
          .from('ufficio_cms_content_blocks')
          .select()
          .eq('procedure_slug', procedureSlug)
          .order('sort_order')
          .timeout(_remoteTimeout);
      final remote = rows
          .map(
            (item) => CmsContentBlock.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      if (remote.isNotEmpty) return remote;
      return fallback;
    } catch (_) {
      return fallback;
    }
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

  List<CmsCategory> _mergeCategories(
    List<CmsCategory> remote,
    List<CmsCategory> fallback,
  ) {
    final bySlug = <String, CmsCategory>{
      for (final item in remote) item.slug: item,
    };
    for (final item in fallback) {
      bySlug.putIfAbsent(item.slug, () => item);
    }
    final merged = bySlug.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return merged;
  }

  List<CmsProcedure> _mergeProcedures(
    List<CmsProcedure> remote,
    List<CmsProcedure> fallback,
  ) {
    final byKey = <String, CmsProcedure>{
      for (final item in remote) '${item.categorySlug}::${item.slug}': item,
    };
    for (final item in fallback) {
      byKey.putIfAbsent('${item.categorySlug}::${item.slug}', () => item);
    }
    final merged = byKey.values.toList()
      ..sort((a, b) {
        final categoryCompare = a.categorySlug.compareTo(b.categorySlug);
        if (categoryCompare != 0) return categoryCompare;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    return merged;
  }
}
