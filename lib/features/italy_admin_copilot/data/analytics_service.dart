abstract class AnalyticsService {
  Future<void> trackCopilotOpened();
  Future<void> trackProcedureSelected(String procedureId);
  Future<void> trackProcedureStarted(String procedureId);
  Future<void> trackValidationFailed(String procedureId);
  Future<void> trackPackGenerated(String procedureId);
  Future<void> trackRequestSaved(String procedureId);
  Future<void> trackPackCopied(String procedureId, String copyType);
  Future<void> trackStatusUpdated(String status);
}

class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> trackCopilotOpened() async {}

  @override
  Future<void> trackPackCopied(String procedureId, String copyType) async {}

  @override
  Future<void> trackPackGenerated(String procedureId) async {}

  @override
  Future<void> trackProcedureSelected(String procedureId) async {}

  @override
  Future<void> trackProcedureStarted(String procedureId) async {}

  @override
  Future<void> trackRequestSaved(String procedureId) async {}

  @override
  Future<void> trackStatusUpdated(String status) async {}

  @override
  Future<void> trackValidationFailed(String procedureId) async {}
}
