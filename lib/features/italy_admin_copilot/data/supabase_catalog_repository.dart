import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/catalog_models.dart';
import 'catalog_repository.dart';

class SupabaseCatalogRepository implements CatalogRepository {
  const SupabaseCatalogRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> _select(String table) async {
    final rows = await _client.from(table).select().eq('is_active', true);
    return rows.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  @override
  Future<List<CatalogSource>> listCatalogSources() async => (await _select(
    'ufficio_catalog_sources',
  )).map(CatalogSource.fromSupabaseJson).toList();

  @override
  Future<List<OfficialLink>> listOfficialLinks() async => (await _select(
    'ufficio_official_links',
  )).map(OfficialLink.fromSupabaseJson).toList();

  @override
  Future<List<OfficialContact>> listOfficialContacts() async => (await _select(
    'ufficio_official_contacts',
  )).map(OfficialContact.fromSupabaseJson).toList();

  @override
  Future<List<ServiceProvider>> listServiceProviders() async {
    final providers = await _select('ufficio_service_providers');
    final forms = await listProviderForms();
    final contacts = await listProviderContactOptions();
    return providers
        .map(
          (item) => ServiceProvider.fromSupabaseJson(
            item,
            forms: forms
                .where((form) => form.providerId == item['id'])
                .toList(),
            contactOptions: contacts
                .where((option) => option.id.startsWith('${item['id']}-'))
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Future<List<ProviderForm>> listProviderForms() async => (await _select(
    'ufficio_provider_forms',
  )).map(ProviderForm.fromSupabaseJson).toList();

  @override
  Future<List<ProviderContactOption>> listProviderContactOptions() async =>
      (await _select(
        'ufficio_provider_contact_options',
      )).map(ProviderContactOption.fromSupabaseJson).toList();

  @override
  Future<List<RegionGuidance>> listRegionGuidance() async =>
      (await _select('ufficio_region_guidance'))
          .map(
            (item) => RegionGuidance.fromJson({
              'id': item['id'],
              'region': item['region'],
              'category': item['category'],
              'title': item['title'],
              'description': item['description'],
              'verificationStatus': item['verification_status'],
              'procedureIds': item['procedure_ids'],
              'portalLinks': item['portal_links'],
              'contactGuidance': item['contact_guidance'],
              'inPersonGuidance': item['in_person_guidance'],
              'sourceUrl': item['source_url'],
              'sourceLabel': item['source_label'],
              'lastVerifiedAt': item['last_verified_at'],
              'warning': item['warning'],
            }),
          )
          .toList();

  @override
  Future<List<CityGuidance>> listCityGuidance() async =>
      (await _select('ufficio_city_guidance'))
          .map(
            (item) => CityGuidance.fromJson({
              'id': item['id'],
              'city': item['city'],
              'region': item['region'],
              'category': item['category'],
              'title': item['title'],
              'description': item['description'],
              'verificationStatus': item['verification_status'],
              'procedureIds': item['procedure_ids'],
              'officeLinks': item['office_links'],
              'contactGuidance': item['contact_guidance'],
              'inPersonGuidance': item['in_person_guidance'],
              'sourceUrl': item['source_url'],
              'sourceLabel': item['source_label'],
              'lastVerifiedAt': item['last_verified_at'],
              'warning': item['warning'],
            }),
          )
          .toList();

  @override
  Future<List<AuthorityGuidance>> listAuthorityGuidance() async =>
      (await _select('ufficio_authority_guidance'))
          .map(
            (item) => AuthorityGuidance.fromJson({
              'id': item['id'],
              'authorityName': item['authority_name'],
              'authorityType': item['authority_type'],
              'category': item['category'],
              'title': item['title'],
              'description': item['description'],
              'verificationStatus': item['verification_status'],
              'procedureIds': item['procedure_ids'],
              'officialLinks': item['official_links'],
              'contactGuidance': item['contact_guidance'],
              'sourceUrl': item['source_url'],
              'sourceLabel': item['source_label'],
              'lastVerifiedAt': item['last_verified_at'],
              'warning': item['warning'],
            }),
          )
          .toList();

  @override
  Future<List<ProcedureGuidance>> listProcedureGuidance() async =>
      (await _select(
        'ufficio_procedure_guidance',
      )).map(ProcedureGuidance.fromSupabaseJson).toList();

  @override
  Future<List<SourceReference>> listSourceReferences() async => (await _select(
    'ufficio_source_references',
  )).map(SourceReference.fromSupabaseJson).toList();

  @override
  Future<List<ServiceTerm>> listServiceTerms() async => (await _select(
    'ufficio_service_terms',
  )).map(ServiceTerm.fromSupabaseJson).toList();

  @override
  Future<List<SubmissionChannel>> listSubmissionChannels() async =>
      (await _select(
        'ufficio_submission_channels',
      )).map(SubmissionChannel.fromSupabaseJson).toList();

  @override
  Future<ProcedureGuidance?> getProcedureGuidance(String procedureId) async {
    final rows = await _client
        .from('ufficio_procedure_guidance')
        .select()
        .eq('procedure_id', procedureId)
        .eq('is_active', true)
        .limit(1);
    if (rows.isEmpty) return null;
    return ProcedureGuidance.fromSupabaseJson(
      Map<String, dynamic>.from(rows.first),
    );
  }

  @override
  Future<ServiceProvider?> getProvider(String providerId) async {
    final rows = await _client
        .from('ufficio_service_providers')
        .select()
        .eq('id', providerId)
        .eq('is_active', true)
        .limit(1);
    if (rows.isEmpty) return null;
    return ServiceProvider.fromSupabaseJson(
      Map<String, dynamic>.from(rows.first),
    );
  }

  @override
  Future<List<ServiceProvider>> getProvidersByCategory(String category) async =>
      (await listServiceProviders())
          .where((item) => item.category == category)
          .toList();

  @override
  Future<CityGuidance?> getCityGuidance(String city) async {
    final all = await listCityGuidance();
    for (final item in all) {
      if (item.city.toLowerCase() == city.toLowerCase()) return item;
    }
    return null;
  }

  @override
  Future<RegionGuidance?> getRegionGuidance(String region) async {
    final all = await listRegionGuidance();
    for (final item in all) {
      if (item.region.toLowerCase() == region.toLowerCase()) return item;
    }
    return null;
  }

  @override
  Future<ServiceTerm?> getTerm(String termId) async {
    final rows = await _client
        .from('ufficio_service_terms')
        .select()
        .eq('id', termId)
        .eq('is_active', true)
        .limit(1);
    if (rows.isEmpty) return null;
    return ServiceTerm.fromSupabaseJson(Map<String, dynamic>.from(rows.first));
  }

  @override
  Future<List<Object>> searchCatalog(String query) async {
    final results = <Object>[];
    results.addAll(await listOfficialLinks());
    results.addAll(await listServiceProviders());
    results.addAll(await listProcedureGuidance());
    final normalized = query.trim().toLowerCase();
    return results.where((item) {
      if (item is OfficialLink) {
        return item.title.toLowerCase().contains(normalized);
      }
      if (item is ServiceProvider) {
        return item.name.toLowerCase().contains(normalized);
      }
      if (item is ProcedureGuidance) {
        return item.title.toLowerCase().contains(normalized);
      }
      return false;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getAppPublicConfig() async {
    final rows = await _select('ufficio_app_public_config');
    return {for (final row in rows) row['key'] as String: row['value']};
  }

  @override
  Future<Map<String, dynamic>> getPremiumPublicConfig() async {
    final rows = await _select('ufficio_premium_public_config');
    return {for (final row in rows) row['key'] as String: row['value']};
  }

  @override
  Future<CatalogHealthSnapshot> getHealthSnapshot() async {
    final links = await listOfficialLinks();
    final providers = await listServiceProviders();
    final procedures = await listProcedureGuidance();
    final terms = await listServiceTerms();
    return CatalogHealthSnapshot(
      remoteConfigured: true,
      remoteAvailable: true,
      usingFallback: false,
      lastFetchAt: DateTime.now(),
      itemCounts: {
        'officialLinks': links.length,
        'providers': providers.length,
        'procedureGuidance': procedures.length,
        'serviceTerms': terms.length,
      },
    );
  }
}
