import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class GenericFormalRequestGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: valueOrPlaceholder(inputData, 'topic', 'Richiesta formale'),
      recipientLabel: 'recipientNameOrOffice',
      requestSummary:
          '${valueOrPlaceholder(inputData, 'request', 'richiedere supporto')} in relazione a ${valueOrPlaceholder(inputData, 'situation', 'situazione da chiarire')}',
      englishExplanation:
          'This pack creates a formal Italian request for a general office, company, provider, landlord, bank, or other recipient.',
    );
  }
}
