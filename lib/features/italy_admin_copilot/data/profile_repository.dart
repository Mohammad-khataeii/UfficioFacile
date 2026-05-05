import '../domain/admin_copilot_profile.dart';

abstract class AdminCopilotProfileRepository {
  Future<AdminCopilotProfile?> getProfile();
  Future<AdminCopilotProfile> saveProfile(AdminCopilotProfile profile);
  Future<void> clearProfile();
}
