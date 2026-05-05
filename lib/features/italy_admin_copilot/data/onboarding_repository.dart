import '../domain/onboarding_state.dart';

abstract class OnboardingRepository {
  Future<OnboardingState> getState();
  Future<void> setCompleted(bool completed);
}
