import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class RentalContractGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    final requestType = valueOrPlaceholder(
      inputData,
      'requestType',
      'variazione contrattuale',
    );
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta aggiornamento contratto di locazione',
      recipientLabel: 'landlordOrAgencyName',
      requestSummary:
          'ottenere chiarimenti e supporto per una richiesta di $requestType relativa al contratto dell’immobile sito in ${valueOrPlaceholder(inputData, 'propertyAddress', 'indirizzo da verificare')}',
      englishExplanation:
          'This pack requests support for adding, replacing, or removing a tenant and asks the landlord, agency, or office to clarify the correct contractual path.',
      warnings: const [
        'È opportuno verificare con l’Agenzia delle Entrate o con un professionista se il caso specifico rientra in subentro, cessione o integrazione contrattuale.',
      ],
      nextSteps: const [
        'Confirm whether any tax registration or contract amendment form is required.',
        'Ask for a written cost breakdown before agreeing to agency or registration fees.',
      ],
    );
  }
}
