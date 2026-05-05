import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class ComuneResidenceGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta anagrafe / residenza',
      recipientLabel: 'cityOrComune',
      requestSummary:
          'ricevere informazioni o aggiornamenti riguardo ${valueOrPlaceholder(inputData, 'requestType', 'una pratica anagrafica')} per ${valueOrPlaceholder(inputData, 'address', 'l’indirizzo indicato')}',
      englishExplanation:
          'This pack asks the Comune or anagrafe office for information, updates, missing document guidance, or certificate help related to residence matters.',
    );
  }
}
