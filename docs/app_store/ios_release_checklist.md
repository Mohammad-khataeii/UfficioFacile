# iOS App Store / TestFlight Checklist

Repository-side iOS release identity:

- Bundle ID: `it.ufficiofacile.app`
- App name: `UfficioFacile`
- Privacy policy URL: [https://ufficio-facile.vercel.app/privacy](https://ufficio-facile.vercel.app/privacy)
- Account deletion URL: [https://ufficio-facile.vercel.app/account-deletion](https://ufficio-facile.vercel.app/account-deletion)
- Deep link scheme: `ufficiofacile://life-admin/profile`

## Local iOS prerequisites

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set your Apple Developer team for the `Runner` target.
3. Confirm the bundle identifier remains `it.ufficiofacile.app`.
4. If you plan to ship ads on iOS, create `ios/Flutter/AdMob.local.xcconfig` locally with:

```xcconfig
ADMOB_APPLICATION_ID_IOS=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

5. Keep `ios/Flutter/AdMob.local.xcconfig` out of git.

## Local verification commands

```bash
/usr/local/share/flutter/bin/dart run tool/apple_release_doctor.dart
/usr/local/share/flutter/bin/flutter analyze
/usr/local/share/flutter/bin/flutter test
```

## iOS production/TestFlight build command

```bash
/usr/local/share/flutter/bin/flutter build ipa \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

Optional iOS ad-related Dart defines:

```bash
  --dart-define=UFFICIOFACILE_ADMOB_BANNER_IOS=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz \
  --dart-define=UFFICIOFACILE_ADMOB_INTERSTITIAL_IOS=ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa
```

Leave those Dart defines unset for the first release if ads are disabled.

## Manual TestFlight / App Store Connect steps

1. Build the IPA locally after signing is configured in Xcode.
2. Upload the build with Xcode Organizer or Transporter.
3. Fill App Privacy answers so they match the published privacy and deletion pages.
4. Add the privacy policy and account deletion URLs in App Store Connect.
5. Test sign-in, checkout, reminders, profile, and account deletion from the TestFlight-installed build.

## Honest readiness note

This repo can be made iOS-release-ready from source control, but Apple signing, provisioning, App Store Connect metadata, upload, and TestFlight review still require manual steps outside the repository.
