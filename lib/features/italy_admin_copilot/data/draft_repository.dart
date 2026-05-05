import '../domain/draft.dart';

abstract class DraftRepository {
  Future<List<DraftEntry>> listDrafts();
  Future<DraftEntry?> getDraft(String procedureId);
  Future<void> saveDraft(DraftEntry draft);
  Future<void> deleteDraft(String procedureId);
}
