import '../domain/service_intelligence.dart';
import 'service_intelligence_definitions.dart';
import 'service_terms_dictionary.dart';

class ServiceIntelligenceQualityService {
  List<ServiceIntelligenceQualityResult> runAll() {
    return ServiceIntelligenceDefinitions.all().map(check).toList();
  }

  ServiceIntelligenceQualityResult check(ServiceIntelligence intelligence) {
    final warnings = <String>[];
    if (intelligence.destinationGuidance.trim().isEmpty) {
      warnings.add('Missing destination guidance.');
    }
    if (intelligence.responsibleAuthorityType.trim().isEmpty) {
      warnings.add('Missing responsible authority type.');
    }
    if (intelligence.officialLinks.isEmpty) {
      warnings.add('Missing official link guidance.');
    }
    if (_containsTerm(intelligence.destinationGuidance, 'PEC') &&
        ServiceTermsDictionary.byId('pec') == null) {
      warnings.add('PEC mentioned without term explanation.');
    }
    if (intelligence.requiredDocumentsDetailed.isEmpty &&
        intelligence.recommendedDocumentsDetailed.isEmpty) {
      warnings.add('Missing detailed document guidance.');
    }
    if (intelligence.beforeSendingChecklist.isEmpty) {
      warnings.add('Missing before-sending checklist.');
    }
    if (intelligence.followUpGuidance.trim().isEmpty) {
      warnings.add('Missing follow-up guidance.');
    }
    if (intelligence.warnings.isEmpty) {
      warnings.add('Missing service warnings.');
    }
    for (final contact in intelligence.officialContactOptions) {
      if (contact.verificationStatus == ServiceVerificationStatus.verified &&
          ((contact.sourceLabel ?? '').isEmpty ||
              (contact.sourceUrl ?? '').isEmpty)) {
        warnings.add(
          'Verified contact ${contact.label} is missing source information.',
        );
      }
      if (contact.verificationStatus == ServiceVerificationStatus.verified &&
          _looksFakeEmail(contact.value)) {
        warnings.add('Verified contact ${contact.label} looks fake.');
      }
    }
    return ServiceIntelligenceQualityResult(
      procedureId: intelligence.procedureId,
      warnings: warnings,
    );
  }

  bool _containsTerm(String value, String term) =>
      value.toLowerCase().contains(term.toLowerCase());

  bool _looksFakeEmail(String value) =>
      value.contains('example.com') || value.contains('example.invalid');
}
