import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class RefundComplaintGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta rimborso / reclamo formale',
      recipientLabel: 'companyOrOffice',
      requestSummary:
          'richiedere ${valueOrPlaceholder(inputData, 'desiredSolution', 'una soluzione')} in merito a ${valueOrPlaceholder(inputData, 'problemDescription', 'un disservizio o problema riscontrato')}',
      englishExplanation:
          'This pack drafts a formal refund or complaint message for a company, transport operator, telecom, bank, insurer, or office.',
    );
  }
}
