import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class RejectedRequestGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    final desiredOutcome = valueOrPlaceholder(
      inputData,
      'desiredOutcome',
      'la rivalutazione della richiesta',
    );
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta di riesame pratica',
      recipientLabel: 'officeName',
      requestSummary:
          'richiedere il riesame della pratica relativa a ${valueOrPlaceholder(inputData, 'originalRequestTopic', 'istanza precedente')} con esito desiderato: $desiredOutcome',
      englishExplanation:
          'This pack replies to a public office rejection, attaches missing evidence if available, and asks for reconsideration.',
      rejectedReplyItalian:
          'Con riferimento al rigetto comunicato in data ${valueOrPlaceholder(inputData, 'rejectionDate', 'data da verificare')}, trasmetto nuovamente la documentazione aggiornata e chiedo cortesemente il riesame della pratica, anche alla luce di ${valueOrPlaceholder(inputData, 'missingDocumentNowAttached', 'ulteriore documentazione ora allegata')}.',
    );
  }
}
