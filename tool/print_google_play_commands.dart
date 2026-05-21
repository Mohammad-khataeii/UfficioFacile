// ignore_for_file: avoid_print

void main() {
  print('UfficioFacile Google Play internal testing commands');
  print('');
  print('1. Generate the local upload keystore');
  print(r'''
keytool -genkeypair \
  -v \
  -keystore "$HOME/ufficiofacile-upload-keystore.jks" \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
''');
  print('2. Create the local signing properties file');
  print(r'''
cp android/key.properties.example android/key.properties
''');
  print('3. Run the repo release doctor');
  print(r'''
/usr/local/share/flutter/bin/dart run tool/google_play_release_doctor.dart
''');
  print('4. Print the Android release info');
  print(r'''
cd android && ./gradlew printAndroidReleaseInfo && cd ..
''');
  print('5. Build the release AAB with ads disabled');
  print(r'''
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
''');
  print('6. Build the release AAB with ads enabled');
  print(r'''
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false \
  --dart-define=UFFICIOFACILE_ADMOB_APP_ID_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy \
  --dart-define=UFFICIOFACILE_ADMOB_BANNER_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz \
  --dart-define=UFFICIOFACILE_ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa
''');
  print('Expected AAB output:');
  print('build/app/outputs/bundle/release/app-release.aab');
}
