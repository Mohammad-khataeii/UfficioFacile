# UfficioFacile mobile ads setup

## Current production-safe behavior

- Free users only: premium users do not see ads.
- Production builds do not fall back to Google test ad IDs.
- If real AdMob IDs are not configured, ads are disabled in production.
- Debug and non-production testing can still use Google test ad IDs only when test mode is explicitly enabled.

## Required production values

Flutter build defines:

- `UFFICIOFACILE_ADMOB_APP_ID_ANDROID`
- `UFFICIOFACILE_ADMOB_BANNER_ANDROID`
- `UFFICIOFACILE_ADMOB_INTERSTITIAL_ANDROID`

Optional future iOS values:

- `UFFICIOFACILE_ADMOB_APP_ID_IOS`
- `UFFICIOFACILE_ADMOB_BANNER_IOS`
- `UFFICIOFACILE_ADMOB_INTERSTITIAL_IOS`

Optional non-production test flag:

- `UFFICIOFACILE_ADMOB_TEST_MODE=true`

## Android manifest behavior

The Android manifest now reads the AdMob app ID from the Gradle placeholder `${admobApplicationId}`.

- Debug and profile builds use Google’s sample app ID for safe SDK initialization.
- Release builds require a real production AdMob app ID if ads are being enabled.
- Leaving the production AdMob values unset disables ads in production instead of showing Google test ads.

## Remote config shape

`ufficio_app_public_config.freeUserAds` can still control screen targeting and the master enable flag:

```json
{
  "enabled": true,
  "provider": "google_mobile_ads",
  "testMode": false,
  "screens": ["home", "profile_folder", "promo_codes"]
}
```

Production unit IDs should come from build-time defines. Do not depend on remote config alone for production ad IDs.

## Play Console declaration

- If ads are enabled in the shipped production build, declare that the app contains ads.
- If ads are disabled in the shipped production build, declare no ads only if the production build truly cannot show ads.
