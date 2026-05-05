class BillAnalysisInput {
  const BillAnalysisInput({
    required this.billType,
    this.providerName,
    this.billPeriod,
    this.amount,
    this.readingType,
    this.consumption,
    this.fixedCharges,
    this.variableCharges,
    this.taxesVat,
    this.hasCanoneRai,
    this.hasPreviousDebt,
    this.hasConguaglio,
    this.contractChangeNotice,
    this.amountSeemsAbnormal,
    this.previousBillAmount,
  });

  final String billType;
  final String? providerName;
  final String? billPeriod;
  final double? amount;
  final String? readingType;
  final double? consumption;
  final double? fixedCharges;
  final double? variableCharges;
  final double? taxesVat;
  final bool? hasCanoneRai;
  final bool? hasPreviousDebt;
  final bool? hasConguaglio;
  final bool? contractChangeNotice;
  final bool? amountSeemsAbnormal;
  final double? previousBillAmount;
}

class BillAnalysisResult {
  const BillAnalysisResult({
    required this.likelyReasons,
    required this.redFlags,
    required this.missingInfo,
    required this.suggestedQuestions,
    required this.recommendedProcedureIds,
    required this.complaintDraftAvailable,
    required this.nextSteps,
  });

  final List<String> likelyReasons;
  final List<String> redFlags;
  final List<String> missingInfo;
  final List<String> suggestedQuestions;
  final List<String> recommendedProcedureIds;
  final bool complaintDraftAvailable;
  final List<String> nextSteps;
}
