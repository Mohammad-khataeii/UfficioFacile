import '../domain/bill_analysis.dart';

class BillAnalysisService {
  BillAnalysisResult analyze(BillAnalysisInput input) {
    final likelyReasons = <String>[];
    final redFlags = <String>[];
    final missingInfo = <String>[];

    if (input.hasConguaglio == true) {
      likelyReasons.add(
        'The bill may be higher because a conguaglio or adjustment is present.',
      );
      redFlags.add('Conguaglio presente');
    }
    if ((input.readingType ?? '').toLowerCase().contains('estimated')) {
      likelyReasons.add('An estimated reading may have increased the bill.');
      redFlags.add('Lettura stimata');
    }
    if (input.hasCanoneRai == true) {
      redFlags.add('Canone RAI presente');
    }
    if (input.contractChangeNotice == true) {
      redFlags.add('Cambio condizioni contrattuali');
    }
    if (input.hasPreviousDebt == true) {
      redFlags.add('Debito precedente o mora');
    }
    if ((input.previousBillAmount ?? 0) > 0 &&
        (input.amount ?? 0) > (input.previousBillAmount! * 1.4)) {
      likelyReasons.add(
        'The bill is significantly higher than the previous one.',
      );
      redFlags.add('Consumo molto più alto del periodo precedente');
    }
    if ((input.fixedCharges ?? 0) > 30) {
      redFlags.add('Costo fisso elevato');
    }
    if (input.providerName == null || input.providerName!.trim().isEmpty) {
      missingInfo.add('Provider name');
    }
    if (input.amount == null) {
      missingInfo.add('Bill amount');
    }
    if (input.consumption == null) {
      missingInfo.add('Consumption');
    }

    return BillAnalysisResult(
      likelyReasons: likelyReasons.isEmpty
          ? const [
              'Not enough signals were entered to explain the bill with confidence.',
            ]
          : likelyReasons,
      redFlags: redFlags,
      missingInfo: missingInfo,
      suggestedQuestions: const [
        'Was the reading estimated or actual?',
        'Is there a conguaglio or previous debt included?',
        'Did the provider change contract conditions or rates recently?',
        'Can you send a detailed breakdown of fixed and variable charges?',
      ],
      recommendedProcedureIds: redFlags.isNotEmpty
          ? const ['HIGH_BILL_COMPLAINT', 'METER_READING_CORRECTION']
          : const ['ENERGY_BILL_ANALYZER_CHECKLIST'],
      complaintDraftAvailable:
          redFlags.contains('Lettura stimata') || redFlags.isNotEmpty,
      nextSteps: const [
        'Compare this bill with the previous one before paying if the amount seems abnormal.',
        'Do not ignore payment deadlines while you request clarification.',
      ],
    );
  }
}
