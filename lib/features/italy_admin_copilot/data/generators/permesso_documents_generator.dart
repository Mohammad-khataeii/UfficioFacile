import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class PermessoDocumentsGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta supporto documentazione permesso di soggiorno',
      recipientLabel: 'officeOrRecipient',
      requestSummary:
          'organizzare o richiedere documentazione relativa a ${valueOrPlaceholder(inputData, 'permessoType', 'permesso di soggiorno')} in vista di ${valueOrPlaceholder(inputData, 'requestType', 'una pratica amministrativa')}',
      englishExplanation:
          'This pack helps organize a permit-related document pack or asks an office, university, or employer for missing supporting documents. It does not provide legal immigration advice.',
      warnings: const [
        'This workflow is for document organization and communication drafting only, not legal immigration advice.',
      ],
    );
  }
}
