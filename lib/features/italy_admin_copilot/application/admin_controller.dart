import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/demo_data_service.dart';
import '../data/generated_pack_quality_service.dart';
import '../data/local_analytics_service.dart';
import '../data/template_override_repository.dart';
import '../domain/generated_pack.dart';
import '../domain/generated_pack_quality.dart';
import '../domain/procedure_template_override.dart';
import '../domain/usage_event.dart';
import 'profile_controller.dart';
import 'request_controller.dart';

class AdminController extends ChangeNotifier {
  AdminController(
    this._templateRepository,
    this._analyticsService,
    this._qualityService,
    this._requestController,
    this._profileController,
  );

  final ProcedureTemplateOverrideRepository _templateRepository;
  final LocalAnalyticsService _analyticsService;
  final GeneratedPackQualityService _qualityService;
  final RequestController _requestController;
  final ProfileController _profileController;
  final DemoDataService _demoDataService = DemoDataService();

  List<ProcedureTemplateOverride> overrides = [];
  List<UsageEvent> events = [];
  GeneratedPackQualityResult? qualityResult;

  Future<void> load() async {
    overrides = await _templateRepository.listOverrides();
    events = _analyticsService.listEvents();
    notifyListeners();
  }

  GeneratedPackQualityResult checkPack(GeneratedPack pack) {
    qualityResult = _qualityService.check(pack);
    notifyListeners();
    return qualityResult!;
  }

  Future<void> saveOverride(ProcedureTemplateOverride override) async {
    await _templateRepository.saveOverride(override);
    await load();
  }

  Future<void> seedDemoData() async {
    final bundle = _demoDataService.build();
    await _profileController.save(bundle.profile);
    for (final request in bundle.requests) {
      await _requestController.savePack(
        procedureId: request.procedureId,
        procedureTitle: request.procedureTitle,
        category: request.category,
        inputData: request.inputData,
        pack: request.generatedPack,
      );
    }
    if (_requestController.requests.isNotEmpty) {
      final firstRequestId = _requestController.requests.first.id;
      for (final reminder in bundle.reminders) {
        await _requestController.addReminder(
          firstRequestId,
          reminder.copyWith(requestId: firstRequestId, id: const Uuid().v4()),
        );
      }
    }
    await load();
  }
}
