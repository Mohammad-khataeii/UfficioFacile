# Google Play release checklist

App identity:

- [ ] Final Android app ID is `it.ufficiofacile.app`
- [ ] `applicationId` and `namespace` both match `it.ufficiofacile.app`
- [ ] `versionCode` has been incremented for this upload
- [ ] `versionName` matches the intended public release version

Signing and artifacts:

- [ ] Upload keystore exists locally and is not committed
- [ ] `android/key.properties` or release signing environment variables are configured
- [ ] Release build is not using debug signing
- [ ] Android App Bundle (`.aab`) built successfully
- [ ] `./gradlew printAndroidReleaseInfo` confirms `releaseSigningConfigured=true`

Android technical quality:

- [ ] `targetSdk >= 35`
- [ ] `compileSdk >= 35`
- [ ] `minSdk` is still compatible with current dependencies
- [ ] `dart run tool/google_play_release_doctor.dart` passes
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Real device smoke test completed

Ads and monetization:

- [ ] No Google sample AdMob app ID or test ad unit IDs are present in production files
- [ ] Production ads are disabled unless real AdMob IDs were provided
- [ ] Play Console ads declaration matches the actual release build
- [ ] Premium checkout and entitlement updates were tested against live Supabase and Stripe

Policy and store content:

- [ ] Privacy policy URL is published
- [ ] Data Safety form is completed
- [ ] Ads declaration is completed
- [ ] Content rating is completed
- [ ] Target audience and content declaration is completed
- [ ] Account deletion route or deletion request path is documented
- [ ] Reviewer instructions are completed
- [ ] Support contact details are set

Release process:

- [ ] Internal testing completed
- [ ] Play pre-launch report reviewed
- [ ] Any crash, ANR, policy, or layout warnings were resolved
- [ ] Supabase auth redirect URLs are configured
- [ ] Internal testing reviewers have working credentials or clear fallback instructions
