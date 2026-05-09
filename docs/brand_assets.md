# Brand Assets

## Concept

Chosen concept: document + checkmark.

Meaning:

- The document represents procedures, forms, and bureaucracy.
- The checkmark represents progress, clarity, and paperwork completed correctly.
- The deep blue base keeps it professional and stable.
- The green accent gives a small sense of success without making the icon noisy.

## Source assets

- `/Users/mohammadkhataei/Desktop/UfficioFacile/assets/brand/ufficiofacile_logo.svg`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/assets/brand/ufficiofacile_icon.svg`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/assets/brand/app_icon_1024.png`

## Generated icon targets

Android:

- `/Users/mohammadkhataei/Desktop/UfficioFacile/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

iOS:

- `/Users/mohammadkhataei/Desktop/UfficioFacile/ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Web:

- `/Users/mohammadkhataei/Desktop/UfficioFacile/web/favicon.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/web/icons/Icon-192.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/web/icons/Icon-512.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/web/icons/Icon-maskable-192.png`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/web/icons/Icon-maskable-512.png`

## Regeneration

Run:

```bash
cd /Users/mohammadkhataei/Desktop/UfficioFacile
python3 tool/generate_brand_icons.py
```

The generation script redraws the icon from code and writes all platform PNGs again.

## Notes

- The source SVG files are simple and editable.
- The PNG icon has extra padding so it survives rounded iOS cropping.
- The shape stays readable at favicon size because it uses only a document form and one checkmark accent.
