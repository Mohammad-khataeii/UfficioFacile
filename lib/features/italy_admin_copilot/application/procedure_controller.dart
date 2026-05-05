import 'package:flutter/foundation.dart';

import '../data/procedure_definitions.dart';
import '../data/procedure_recommendation_service.dart';
import '../domain/admin_procedure.dart';
import '../domain/procedure_recommendation.dart';

class ProcedureController extends ChangeNotifier {
  final ProcedureRecommendationService _recommendationService =
      ProcedureRecommendationService();

  List<AdminProcedure> procedures = ItalyAdminProcedureDefinitions.all();

  List<AdminProcedure> search({
    String query = '',
    ProcedureCategory? category,
  }) {
    return procedures.where((procedure) {
      final matchesQuery =
          query.trim().isEmpty ||
          procedure.title.toLowerCase().contains(query.toLowerCase()) ||
          procedure.shortDescription.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          procedure.tags.any(
            (tag) => tag.toLowerCase().contains(query.toLowerCase()),
          );
      final matchesCategory =
          category == null || procedure.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<ProcedureRecommendation> recommend(String userProblem) {
    return _recommendationService.recommend(userProblem);
  }
}
