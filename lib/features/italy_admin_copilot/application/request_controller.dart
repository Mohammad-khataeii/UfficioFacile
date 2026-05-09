import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/draft_repository.dart';
import '../data/local_analytics_service.dart';
import '../data/request_repository.dart';
import '../domain/admin_request.dart';
import '../domain/draft.dart';
import '../domain/generated_pack.dart';
import '../domain/reminder.dart';
import '../domain/request_status.dart';

class RequestController extends ChangeNotifier {
  RequestController(
    this._repository,
    this._draftRepository,
    this._analyticsService,
  );

  final AdminCopilotRequestRepository _repository;
  final DraftRepository _draftRepository;
  final LocalAnalyticsService _analyticsService;
  final Uuid _uuid = const Uuid();

  List<AdminCopilotRequest> requests = [];

  Future<void> load() async {
    requests = await _repository.listRequests();
    notifyListeners();
  }

  Future<AdminCopilotRequest> savePack({
    required String procedureId,
    required String procedureTitle,
    required String category,
    required Map<String, dynamic> inputData,
    required GeneratedPack pack,
  }) async {
    final requestId = _uuid.v4();
    final request = AdminCopilotRequest(
      id: requestId,
      procedureId: procedureId,
      procedureTitle: procedureTitle,
      category: category,
      status: RequestStatus.generated,
      priority: pack.priority,
      inputData: inputData,
      generatedPack: pack,
      subject: pack.subject,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reminders: [],
      statusEvents: [
        StatusEvent(
          id: _uuid.v4(),
          requestId: requestId,
          newStatus: RequestStatus.generated,
          createdAt: DateTime.now(),
        ),
      ],
    );
    final saved = await _repository.createRequest(request);
    requests = await _repository.listRequests();
    await _analyticsService.trackRequestSaved(procedureId);
    notifyListeners();
    return saved;
  }

  Future<void> updateStatus(String id, RequestStatus status) async {
    await _repository.updateStatus(id, status);
    requests = await _repository.listRequests();
    await _analyticsService.trackStatusUpdated(status.name);
    notifyListeners();
  }

  Future<void> saveNotes(String id, String notes) async {
    final existing = await _repository.getRequest(id);
    if (existing == null) return;
    await _repository.updateRequest(
      existing.copyWith(notes: notes, updatedAt: DateTime.now()),
    );
    requests = await _repository.listRequests();
    notifyListeners();
  }

  Future<void> toggleAttachment(
    String requestId,
    String attachmentId,
    bool checked,
  ) async {
    final existing = await _repository.getRequest(requestId);
    if (existing == null) return;
    final updatedChecklist = existing.generatedPack.attachmentChecklist
        .map(
          (item) => item.id == attachmentId
              ? item.copyWith(userHasIt: checked)
              : item,
        )
        .toList();
    final updated = existing.copyWith(
      generatedPack: existing.generatedPack.copyWith(
        attachmentChecklist: updatedChecklist,
        updatedAt: DateTime.now(),
      ),
      updatedAt: DateTime.now(),
    );
    await _repository.updateRequest(updated);
    requests = await _repository.listRequests();
    notifyListeners();
  }

  Future<void> addReminder(String requestId, Reminder reminder) async {
    final existing = await _repository.getRequest(requestId);
    if (existing == null) return;
    await _repository.updateRequest(
      existing.copyWith(
        reminders: [...existing.reminders, reminder],
        updatedAt: DateTime.now(),
      ),
    );
    requests = await _repository.listRequests();
    notifyListeners();
  }

  Future<void> markReminderDone(String requestId, String reminderId) async {
    final existing = await _repository.getRequest(requestId);
    if (existing == null) return;
    final reminders = existing.reminders
        .map(
          (item) => item.id == reminderId ? item.copyWith(isDone: true) : item,
        )
        .toList();
    await _repository.updateRequest(
      existing.copyWith(reminders: reminders, updatedAt: DateTime.now()),
    );
    requests = await _repository.listRequests();
    notifyListeners();
  }

  Future<void> deleteRequest(String id) async {
    await _repository.deleteRequest(id);
    requests = await _repository.listRequests();
    notifyListeners();
  }

  Future<void> saveDraft(
    String procedureId,
    Map<String, dynamic> inputData,
  ) async {
    await _draftRepository.saveDraft(
      DraftEntry(
        id: _uuid.v4(),
        procedureId: procedureId,
        inputData: inputData,
        updatedAt: DateTime.now(),
      ),
    );
    await _analyticsService.trackStatusUpdated('form_draft_saved');
  }

  Future<DraftEntry?> getDraft(String procedureId) {
    return _draftRepository.getDraft(procedureId);
  }

  Future<void> clearDraft(String procedureId) {
    return _draftRepository.deleteDraft(procedureId);
  }

  Future<void> clearLocalState() async {
    requests = const [];
    notifyListeners();
  }
}
