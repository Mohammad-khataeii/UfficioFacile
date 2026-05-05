import '../domain/admin_request.dart';
import '../domain/request_status.dart';
import 'request_repository.dart';

class RemoteAdminCopilotRequestRepository
    implements AdminCopilotRequestRepository {
  const RemoteAdminCopilotRequestRepository();

  @override
  Future<AdminCopilotRequest> createRequest(AdminCopilotRequest request) async {
    throw UnimplementedError(
      'Remote repository is backend-ready but not wired because this project '
      'does not yet include an authenticated backend pattern.',
    );
  }

  @override
  Future<void> deleteRequest(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<AdminCopilotRequest?> getRequest(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<AdminCopilotRequest>> listRequests() async {
    throw UnimplementedError();
  }

  @override
  Future<AdminCopilotRequest> updateRequest(AdminCopilotRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<AdminCopilotRequest> updateStatus(
    String id,
    RequestStatus status, {
    String? note,
  }) async {
    throw UnimplementedError();
  }
}
