import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class LandlordIssueGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta intervento / chiarimento contratto locazione',
      recipientLabel: 'landlordOrAgencyName',
      requestSummary:
          'richiedere un intervento o un chiarimento in merito a ${valueOrPlaceholder(inputData, 'issueType', 'una problematica nell’immobile')} presso ${valueOrPlaceholder(inputData, 'propertyAddress', 'indirizzo da verificare')}',
      englishExplanation:
          'This pack formally notifies a landlord or agency about maintenance, safety, deposit, or contract issues and asks for corrective action.',
      warnings: [
        if (inputData['previousMessagesSent'] == true)
          'Keep copies of earlier messages and photos in case the issue escalates.',
      ],
    );
  }
}
