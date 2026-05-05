import 'package:flutter/foundation.dart';

import '../data/profile_repository.dart';
import '../domain/admin_copilot_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final AdminCopilotProfileRepository _repository;
  AdminCopilotProfile profile = const AdminCopilotProfile();

  Future<void> load() async {
    profile = await _repository.getProfile() ?? const AdminCopilotProfile();
    notifyListeners();
  }

  Future<void> save(AdminCopilotProfile next) async {
    profile = await _repository.saveProfile(next);
    notifyListeners();
  }
}
