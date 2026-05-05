import 'package:flutter/foundation.dart';

import '../data/bill_analysis_service.dart';
import '../data/canone_rai_service.dart';
import '../data/utility_comparison_service.dart';
import '../domain/bill_analysis.dart';
import '../domain/canone_rai_models.dart';
import '../domain/utility_comparison.dart';

class UtilityController extends ChangeNotifier {
  final UtilityComparisonService comparisonService = UtilityComparisonService();
  final BillAnalysisService billAnalysisService = BillAnalysisService();
  final CanoneRaiService canoneRaiService = CanoneRaiService();

  UtilityComparisonResult? comparisonResult;
  BillAnalysisResult? billAnalysisResult;
  CanoneRaiDecisionResult? canoneDecisionResult;

  void compare(UtilityComparisonInput input) {
    comparisonResult = comparisonService.compare(input);
    notifyListeners();
  }

  void analyzeBill(BillAnalysisInput input) {
    billAnalysisResult = billAnalysisService.analyze(input);
    notifyListeners();
  }

  void evaluateCanone(CanoneRaiDecisionInput input) {
    canoneDecisionResult = canoneRaiService.evaluate(input);
    notifyListeners();
  }
}
