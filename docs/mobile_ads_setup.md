# UfficioFacile mobile ads setup

This app now has a real ad structure for free users.

## What is already implemented

- Free users only: premium users do not see ads.
- Google Mobile Ads SDK wiring for Android and iOS.
- Remote ad screen control through `ufficio_app_public_config`.
- Reusable banner slots in the app on:
  - `home`
  - `profile_folder`
  - `promo_codes`

## Important before going live

The native app currently uses Google test app IDs so the SDK can start safely.
Before publishing, replace them with your real AdMob app IDs.

Files:

- Android: [/Users/mohammadkhataei/Desktop/UfficioFacile/android/app/src/main/AndroidManifest.xml](/Users/mohammadkhataei/Desktop/UfficioFacile/android/app/src/main/AndroidManifest.xml)
- iOS: [/Users/mohammadkhataei/Desktop/UfficioFacile/ios/Runner/Info.plist](/Users/mohammadkhataei/Desktop/UfficioFacile/ios/Runner/Info.plist)

## 1. Apply for AdMob

1. Create or sign in to your Google AdMob account.
2. Add the Android and iOS apps.
3. Create banner ad units for the placements you want.
4. Keep the app IDs and banner unit IDs ready.

## 2. Replace native app IDs

Android manifest:

- Replace `ca-app-pub-3940256099942544~3347511713`

iOS Info.plist:

- Replace `ca-app-pub-3940256099942544~1458002511`

These are Google test IDs. They must not stay in production if you want real revenue.

## 3. Configure banner unit IDs from admin

Open the admin panel `Config` page and edit `ufficio_app_public_config` key:

- `freeUserAds`

Recommended value shape:

```json
{
  "enabled": true,
  "provider": "google_mobile_ads",
  "testMode": false,
  "screens": ["home", "profile_folder", "promo_codes"],
  "bannerUnitIdAndroid": "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx",
  "bannerUnitIdIos": "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx",
  "interstitialUnitIdAndroid": "",
  "interstitialUnitIdIos": ""
}
```

## 4. How screen targeting works

- `enabled`: master switch
- `provider`: currently `google_mobile_ads`
- `screens`: where ads may appear
- `bannerUnitIdAndroid` and `bannerUnitIdIos`: real monetized banner units

If `enabled` is `false`, no ads are shown.

If the unit ID is empty, the app falls back to Google test units. That is safe for testing, but it does not monetize.

## 5. How to add more ad placements

Widget:

- [notification_and_monetization_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/notification_and_monetization_screens.dart)

Reusable widget:

- `FreeUserBannerAdCard(screen: 'your_screen_key')`

Steps:

1. Add the widget to the target screen.
2. Add the same screen key to `freeUserAds.screens`.
3. Save config in admin.

## 6. Good rollout defaults

- Start with banner only.
- Keep ads on utility screens, not every screen.
- Avoid putting ads above the main call to action.
- Keep premium screens and locked premium content ad-free.

## 7. Troubleshooting

If ads do not show:

1. Check that the user is free, not premium.
2. Check `freeUserAds.enabled`.
3. Check the screen key exists in `freeUserAds.screens`.
4. Check the real banner unit ID for the correct platform.
5. Confirm the native AdMob app ID was replaced.
6. Test on a physical device, not only emulator/web.

## 8. Safe production note

The app is set up so ads can be disabled instantly from admin config without shipping a new build.
