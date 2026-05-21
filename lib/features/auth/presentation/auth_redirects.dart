String _webOriginOrDefault() {
  final scheme = Uri.base.scheme;
  final origin = scheme == 'http' || scheme == 'https' ? Uri.base.origin : '';
  if (origin.isNotEmpty) {
    return origin;
  }
  return 'https://ufficio-facile.vercel.app';
}

String buildEmailConfirmationRedirectUri() {
  return '${_webOriginOrDefault()}/auth/confirm-email-callback';
}

String buildPasswordResetRedirectUri() {
  return '${_webOriginOrDefault()}/auth/reset-password-callback';
}

String buildNativeEmailConfirmationDeepLink() {
  return 'ufficiofacile://auth/confirm-email';
}

String buildNativePasswordResetDeepLink() {
  return 'ufficiofacile://auth/reset-password';
}
