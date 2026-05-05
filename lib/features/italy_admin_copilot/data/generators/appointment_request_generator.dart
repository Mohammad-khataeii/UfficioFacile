import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class AppointmentRequestGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta appuntamento',
      recipientLabel: 'recipient',
      requestSummary:
          'richiedere un appuntamento per ${valueOrPlaceholder(inputData, 'reason', 'motivo da specificare')}',
      englishExplanation:
          'This pack asks a public office, patronato, CAF, landlord, consultant, or professional for a formal appointment.',
    );
  }
}
