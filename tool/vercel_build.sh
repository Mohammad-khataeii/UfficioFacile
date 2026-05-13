#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter not found. Installing stable Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
else
  echo "Flutter found."
fi

if ! command -v dart >/dev/null 2>&1; then
  export PATH="$(dirname "$(command -v flutter)")/cache/dart-sdk/bin:$PATH"
fi

flutter --version
flutter pub get
dart run tool/export_cms_seed.dart
dart run tool/validate_catalog.dart

flutter build web --release \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE="${UFFICCIOFACILE_BACKEND_MODE:-supabase}" \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:?SUPABASE_URL is required}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY is required}" \
  --dart-define=UFFICCIOFACILE_ENABLE_SYNC="${UFFICCIOFACILE_ENABLE_SYNC:-true}" \
  --dart-define=UFFICCIOFACILE_ENABLE_ADMIN_DEBUG="${UFFICCIOFACILE_ENABLE_ADMIN_DEBUG:-false}" \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE="${UFFICCIOFACILE_ENABLE_BETA_MODE:-false}" \
  --dart-define=UFFICCIOFACILE_ALLOW_LEGACY_CATALOG_FALLBACK=false \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL="${UFFICCIOFACILE_ENABLE_PAYWALL:-true}" \
  --dart-define=UFFICCIOFACILE_ENABLE_ANALYTICS="${UFFICCIOFACILE_ENABLE_ANALYTICS:-true}"
