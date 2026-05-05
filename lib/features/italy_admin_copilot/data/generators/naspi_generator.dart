import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class NaspiGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta appuntamento e checklist NASpI',
      recipientLabel: 'patronatoOrCafName',
      requestSummary:
          'richiedere un appuntamento e la verifica della documentazione utile per la preparazione della pratica NASpI dopo la cessazione del rapporto con ${valueOrPlaceholder(inputData, 'employer', 'il datore di lavoro')}',
      englishExplanation:
          'This pack asks a patronato or CAF for an appointment and a document checklist to prepare a NASpI unemployment benefits application.',
      nextSteps: const [
        'Collect termination paperwork, payslips, IBAN details, and any communication from the employer before the appointment.',
      ],
    );
  }
}
