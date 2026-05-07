enum EntitySyncState {
  localOnly,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  synced,
  conflict,
  failed,
}

enum SyncStatusState {
  localOnly,
  disabled,
  unavailable,
  syncing,
  synced,
  failed,
  conflict,
}

class SyncStatus {
  const SyncStatus({
    required this.state,
    this.lastSyncAt,
    this.pendingChanges = 0,
    this.lastError,
  });

  final SyncStatusState state;
  final DateTime? lastSyncAt;
  final int pendingChanges;
  final String? lastError;
}

class SyncLogEntry {
  const SyncLogEntry({
    required this.syncType,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.errorCode,
    this.errorMessage,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.conflictCount = 0,
  });

  final String syncType;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? errorCode;
  final String? errorMessage;
  final int pushedCount;
  final int pulledCount;
  final int conflictCount;
}
