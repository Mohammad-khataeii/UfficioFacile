import '../domain/catalog_models.dart';

class CatalogHealthSnapshot {
  const CatalogHealthSnapshot({
    required this.remoteConfigured,
    required this.remoteAvailable,
    required this.usingFallback,
    required this.lastFetchAt,
    required this.itemCounts,
  });

  final bool remoteConfigured;
  final bool remoteAvailable;
  final bool usingFallback;
  final DateTime? lastFetchAt;
  final Map<String, int> itemCounts;
}

abstract class CatalogRepository {
  Future<List<CatalogSource>> listCatalogSources();
  Future<List<OfficialLink>> listOfficialLinks();
  Future<List<OfficialContact>> listOfficialContacts();
  Future<List<ServiceProvider>> listServiceProviders();
  Future<List<ProviderForm>> listProviderForms();
  Future<List<ProviderContactOption>> listProviderContactOptions();
  Future<List<RegionGuidance>> listRegionGuidance();
  Future<List<CityGuidance>> listCityGuidance();
  Future<List<AuthorityGuidance>> listAuthorityGuidance();
  Future<List<ProcedureGuidance>> listProcedureGuidance();
  Future<List<SourceReference>> listSourceReferences();
  Future<List<ServiceTerm>> listServiceTerms();
  Future<List<SubmissionChannel>> listSubmissionChannels();
  Future<ProcedureGuidance?> getProcedureGuidance(String procedureId);
  Future<ServiceProvider?> getProvider(String providerId);
  Future<List<ServiceProvider>> getProvidersByCategory(String category);
  Future<CityGuidance?> getCityGuidance(String city);
  Future<RegionGuidance?> getRegionGuidance(String region);
  Future<ServiceTerm?> getTerm(String termId);
  Future<List<Object>> searchCatalog(String query);
  Future<Map<String, dynamic>> getAppPublicConfig();
  Future<Map<String, dynamic>> getPremiumPublicConfig();
  Future<CatalogHealthSnapshot> getHealthSnapshot();
}
