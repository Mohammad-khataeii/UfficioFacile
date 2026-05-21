# Local signing step by step

This guide is for local Google Play Internal Testing preparation only.

Never commit:

- `android/key.properties`
- `*.jks`
- `*.keystore`
- `upload-keystore.jks`
- real passwords or private keys

## 1. Generate the upload keystore locally

Run on macOS:

```bash
keytool -genkeypair \
  -v \
  -keystore "$HOME/ufficiofacile-upload-keystore.jks" \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

This creates the upload key you will use to sign the Play upload artifact.

Important:

- never lose this key
- never commit this key
- keep a secure backup outside the repo

## 2. Create the local signing properties file

From the repo root:

```bash
cp android/key.properties.example android/key.properties
```

Then edit `android/key.properties` locally.

Example with placeholders only:

```properties
storeFile=/Users/your-name/ufficiofacile-upload-keystore.jks
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=upload
keyPassword=YOUR_KEY_PASSWORD
```

What each property means:

- `storeFile`: absolute path to the local keystore file
- `storePassword`: password protecting the keystore file
- `keyAlias`: alias of the key inside the keystore, usually `upload`
- `keyPassword`: password for that key alias

## 3. Keep the signing files out of git

The repo already ignores:

- `android/key.properties`
- `*.jks`
- `*.keystore`
- `upload-keystore.jks`

Verify the files are ignored:

```bash
git check-ignore -v android/key.properties "$HOME/ufficiofacile-upload-keystore.jks"
```

Verify they are not tracked:

```bash
git ls-files android/key.properties '*.jks' '*.keystore' upload-keystore.jks
```

That command should print nothing.

## 4. Run the repo checks

```bash
/usr/local/share/flutter/bin/dart run tool/google_play_release_doctor.dart
/usr/local/share/flutter/bin/dart run tool/print_google_play_commands.dart
cd android && ./gradlew printAndroidReleaseInfo && cd ..
```

## 5. Build the release AAB

Ads disabled:

```bash
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

Ads enabled:

```bash
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
```

Expected output:

```text
build/app/outputs/bundle/release/app-release.aab
```

## 6. If Gradle says release signing is not configured

Check:

- `android/key.properties` exists locally
- `storeFile` points to a real keystore path
- `storePassword` is filled in
- `keyAlias` matches the keystore alias
- `keyPassword` is filled in

Alternative:

- set `ANDROID_KEYSTORE_PATH`
- set `ANDROID_KEYSTORE_PASSWORD`
- set `ANDROID_KEY_ALIAS`
- set `ANDROID_KEY_PASSWORD`

Do not put those secrets in git or docs.
