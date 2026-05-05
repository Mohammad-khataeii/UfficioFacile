class OnboardingState {
  const OnboardingState({required this.completed, this.completedAt});

  final bool completed;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() => {
    'completed': completed,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      OnboardingState(
        completed: json['completed'] as bool? ?? false,
        completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      );
}
