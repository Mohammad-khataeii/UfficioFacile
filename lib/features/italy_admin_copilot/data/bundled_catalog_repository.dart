import '../domain/catalog_models.dart';
import 'catalog/bundled_authority_guidance.dart';
import 'catalog/bundled_catalog_sources.dart';
import 'catalog/bundled_city_guidance.dart';
import 'catalog/bundled_official_contacts.dart';
import 'catalog/bundled_official_links.dart';
import 'catalog/bundled_procedure_guidance.dart';
import 'catalog/bundled_provider_forms.dart';
import 'catalog/bundled_region_guidance.dart';
import 'catalog/bundled_service_providers.dart';
import 'catalog/bundled_service_terms.dart';
import 'catalog/bundled_source_references.dart';
import 'catalog/bundled_submission_channels.dart';
import 'catalog_repository.dart';

class BundledCatalogRepository implements CatalogRepository {
  const BundledCatalogRepository();

  @override
  Future<List<CatalogSource>> listCatalogSources() async =>
      bundledCatalogSources;

  @override
  Future<List<OfficialLink>> listOfficialLinks() async => bundledOfficialLinks;

  @override
  Future<List<OfficialContact>> listOfficialContacts() async =>
      bundledOfficialContacts;

  @override
  Future<List<ServiceProvider>> listServiceProviders() async =>
      bundledServiceProviders;

  @override
  Future<List<ProviderForm>> listProviderForms() async => bundledProviderForms;

  @override
  Future<List<ProviderContactOption>> listProviderContactOptions() async =>
      bundledServiceProviders.expand((item) => item.contactOptions).toList();

  @override
  Future<List<RegionGuidance>> listRegionGuidance() async =>
      bundledRegionGuidance;

  @override
  Future<List<CityGuidance>> listCityGuidance() async => bundledCityGuidance;

  @override
  Future<List<AuthorityGuidance>> listAuthorityGuidance() async =>
      bundledAuthorityGuidance;

  @override
  Future<List<ProcedureGuidance>> listProcedureGuidance() async =>
      bundledProcedureGuidance;

  @override
  Future<List<SourceReference>> listSourceReferences() async =>
      bundledSourceReferences;

  @override
  Future<List<ServiceTerm>> listServiceTerms() async => bundledServiceTerms;

  @override
  Future<List<SubmissionChannel>> listSubmissionChannels() async =>
      bundledSubmissionChannels;

  @override
  Future<ProcedureGuidance?> getProcedureGuidance(String procedureId) async {
    for (final item in bundledProcedureGuidance) {
      if (item.procedureId == procedureId) return item;
    }
    return null;
  }

  @override
  Future<ServiceProvider?> getProvider(String providerId) async {
    for (final item in bundledServiceProviders) {
      if (item.id == providerId) return item;
    }
    return null;
  }

  @override
  Future<List<ServiceProvider>> getProvidersByCategory(String category) async =>
      bundledServiceProviders
          .where((item) => item.category == category)
          .toList();

  @override
  Future<CityGuidance?> getCityGuidance(String city) async {
    for (final item in bundledCityGuidance) {
      if (item.city.toLowerCase() == city.toLowerCase()) return item;
    }
    return null;
  }

  @override
  Future<RegionGuidance?> getRegionGuidance(String region) async {
    for (final item in bundledRegionGuidance) {
      if (item.region.toLowerCase() == region.toLowerCase()) return item;
    }
    return null;
  }

  @override
  Future<ServiceTerm?> getTerm(String termId) async {
    for (final item in bundledServiceTerms) {
      if (item.id == termId) return item;
    }
    return null;
  }

  @override
  Future<List<Object>> searchCatalog(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const <Object>[];
    final results = <Object>[];
    results.addAll(
      bundledOfficialLinks.where(
        (item) =>
            item.title.toLowerCase().contains(normalized) ||
            item.descriptionLocalized.values.any(
              (value) => value.toLowerCase().contains(normalized),
            ),
      ),
    );
    results.addAll(
      bundledServiceProviders.where(
        (item) => item.name.toLowerCase().contains(normalized),
      ),
    );
    results.addAll(
      bundledProcedureGuidance.where(
        (item) =>
            item.title.toLowerCase().contains(normalized) ||
            item.summary.values.any(
              (value) => value.toLowerCase().contains(normalized),
            ),
      ),
    );
    return results;
  }

  @override
  Future<Map<String, dynamic>> getAppPublicConfig() async => const {
    'userAuthRequired': false,
    'publicCatalogMode': 'bundled',
    'freeUserAds': {
      'enabled': false,
      'provider': 'google_mobile_ads',
      'testMode': false,
      'screens': ['home', 'profile_folder', 'promo_codes'],
      'bannerUnitIdAndroid': '',
      'bannerUnitIdIos': '',
      'interstitialUnitIdAndroid': '',
      'interstitialUnitIdIos': '',
    },
  };

  @override
  Future<Map<String, dynamic>> getPremiumPublicConfig() async => const {
    'betaModeEnabled': false,
    'paywallEnabled': true,
  };

  @override
  Future<CatalogHealthSnapshot> getHealthSnapshot() async =>
      CatalogHealthSnapshot(
        remoteConfigured: false,
        remoteAvailable: false,
        usingFallback: true,
        lastFetchAt: null,
        itemCounts: {
          'officialLinks': bundledOfficialLinks.length,
          'officialContacts': bundledOfficialContacts.length,
          'providers': bundledServiceProviders.length,
          'procedureGuidance': bundledProcedureGuidance.length,
          'sourceReferences': bundledSourceReferences.length,
          'serviceTerms': bundledServiceTerms.length,
          'submissionChannels': bundledSubmissionChannels.length,
        },
      );
}
