import '../domain/admin_request.dart';
import '../domain/request_status.dart';

abstract class AdminCopilotRequestRepository {
  Future<List<AdminCopilotRequest>> listRequests();
  Future<AdminCopilotRequest?> getRequest(String id);
  Future<AdminCopilotRequest> createRequest(AdminCopilotRequest request);
  Future<AdminCopilotRequest> updateRequest(AdminCopilotRequest request);
  Future<void> deleteRequest(String id);
  Future<AdminCopilotRequest> updateStatus(
    String id,
    RequestStatus status, {
    String? note,
  });
}
