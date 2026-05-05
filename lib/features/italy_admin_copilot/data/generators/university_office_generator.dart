import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class UniversityOfficeGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta supporto ufficio universitario',
      recipientLabel: 'officeName',
      requestSummary:
          'ricevere supporto sul tema ${valueOrPlaceholder(inputData, 'topic', 'amministrativo universitario')} per lo/la studente/ssa ${valueOrPlaceholder(inputData, 'studentName', 'interessato/a')}',
      englishExplanation:
          'This pack asks a university office for help with an administrative issue such as enrollment, fees, scholarships, ISEE, or residence permit-related student documents.',
    );
  }
}
