class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.isAnonymous,
  });

  final String id;
  final String email;
  final bool isAnonymous;

  bool get isAuthenticated => id.isNotEmpty;
}
