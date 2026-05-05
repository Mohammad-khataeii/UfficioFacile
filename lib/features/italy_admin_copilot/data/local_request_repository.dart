import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/admin_request.dart';
import '../domain/request_status.dart';
import 'request_repository.dart';

class LocalAdminCopilotRequestRepository
    implements AdminCopilotRequestRepository {
  LocalAdminCopilotRequestRepository(this._prefs, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  static const requestsStorageKey = 'italy_life_admin_requests_v1';
  static const draftsStorageKey = 'italy_life_admin_drafts_v1';

  final SharedPreferences _prefs;
  final Uuid _uuid;

  List<AdminCopilotRequest> _readRequests() {
    final raw = _prefs.getString(requestsStorageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                AdminCopilotRequest.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeRequests(List<AdminCopilotRequest> requests) async {
    await _prefs.setString(
      requestsStorageKey,
      jsonEncode(requests.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<AdminCopilotRequest> createRequest(AdminCopilotRequest request) async {
    final items = _readRequests();
    items.removeWhere((item) => item.id == request.id);
    items.add(request);
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _writeRequests(items);
    return request;
  }

  @override
  Future<void> deleteRequest(String id) async {
    final items = _readRequests()..removeWhere((item) => item.id == id);
    await _writeRequests(items);
  }

  @override
  Future<AdminCopilotRequest?> getRequest(String id) async {
    final items = _readRequests();
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<AdminCopilotRequest>> listRequests() async {
    return _readRequests();
  }

  @override
  Future<AdminCopilotRequest> updateRequest(AdminCopilotRequest request) async {
    final items = _readRequests();
    final index = items.indexWhere((item) => item.id == request.id);
    if (index == -1) {
      items.add(request);
    } else {
      items[index] = request;
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _writeRequests(items);
    return request;
  }

  @override
  Future<AdminCopilotRequest> updateStatus(
    String id,
    RequestStatus status, {
    String? note,
  }) async {
    final request = await getRequest(id);
    if (request == null) {
      throw StateError('Request not found: $id');
    }
    final now = DateTime.now();
    final updated = request.copyWith(
      status: status,
      updatedAt: now,
      sentAt: status == RequestStatus.sent ? now : request.sentAt,
      repliedAt: status == RequestStatus.replied ? now : request.repliedAt,
      completedAt: status == RequestStatus.completed
          ? now
          : request.completedAt,
      statusEvents: [
        ...request.statusEvents,
        StatusEvent(
          id: _uuid.v4(),
          requestId: request.id,
          oldStatus: request.status,
          newStatus: status,
          note: note,
          createdAt: now,
        ),
      ],
      generatedPack: request.generatedPack.copyWith(
        status: status,
        updatedAt: now,
      ),
    );
    await updateRequest(updated);
    return updated;
  }

  Future<void> saveDraft(String procedureId, Map<String, dynamic> draft) async {
    final allDrafts = await readDrafts();
    allDrafts[procedureId] = draft;
    await _prefs.setString(draftsStorageKey, jsonEncode(allDrafts));
  }

  Future<Map<String, dynamic>?> loadDraft(String procedureId) async {
    final allDrafts = await readDrafts();
    final draft = allDrafts[procedureId];
    if (draft is Map<String, dynamic>) {
      return draft;
    }
    if (draft is Map) {
      return Map<String, dynamic>.from(draft);
    }
    return null;
  }

  Future<void> clearDraft(String procedureId) async {
    final allDrafts = await readDrafts();
    allDrafts.remove(procedureId);
    await _prefs.setString(draftsStorageKey, jsonEncode(allDrafts));
  }

  Future<Map<String, dynamic>> readDrafts() async {
    final raw = _prefs.getString(draftsStorageKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      await _prefs.remove(draftsStorageKey);
    }
    return {};
  }
}
