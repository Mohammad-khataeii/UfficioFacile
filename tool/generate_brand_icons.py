from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent.parent
BRAND_DIR = ROOT / "assets" / "brand"
SOURCE_PNG = BRAND_DIR / "app_icon_1024.png"

IOS_ICONSET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
ANDROID_MIPMAPS = {
    "mipmap-mdpi/ic_launcher.png": 48,
    "mipmap-hdpi/ic_launcher.png": 72,
    "mipmap-xhdpi/ic_launcher.png": 96,
    "mipmap-xxhdpi/ic_launcher.png": 144,
    "mipmap-xxxhdpi/ic_launcher.png": 192,
}
WEB_ICONS = {
    "web/favicon.png": 32,
    "web/icons/Icon-192.png": 192,
    "web/icons/Icon-512.png": 512,
    "web/icons/Icon-maskable-192.png": 192,
    "web/icons/Icon-maskable-512.png": 512,
}
IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}


def rounded_rect(draw: ImageDraw.ImageDraw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def create_source_icon(size: int = 1024) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    navy = "#123B5D"
    light = "#F8FBFF"
    fold = "#D9EAF7"
    line = "#D0DDEA"
    green = "#2FBF71"

    rounded_rect(draw, (0, 0, size, size), int(size * 0.23), navy)

    doc_left = int(size * 0.27)
    doc_top = int(size * 0.18)
    doc_right = int(size * 0.73)
    doc_bottom = int(size * 0.79)
    rounded_rect(
        draw,
        (doc_left, doc_top, doc_right, doc_bottom),
        int(size * 0.05),
        light,
    )

    fold_size = int(size * 0.12)
    draw.polygon(
        [
            (doc_right - fold_size, doc_top),
            (doc_right, doc_top + fold_size),
            (doc_right - fold_size + int(size * 0.03), doc_top + fold_size),
            (doc_right - fold_size, doc_top + int(size * 0.03)),
        ],
        fill=fold,
    )

    bar_left = int(size * 0.34)
    for top, width_factor in ((0.38, 0.32), (0.46, 0.26), (0.54, 0.22)):
        y = int(size * top)
        rounded_rect(
            draw,
            (bar_left, y, bar_left + int(size * width_factor), y + int(size * 0.035)),
            int(size * 0.018),
            line,
        )

    badge_center = (int(size * 0.70), int(size * 0.70))
    badge_radius = int(size * 0.12)
    draw.ellipse(
        (
            badge_center[0] - badge_radius,
            badge_center[1] - badge_radius,
            badge_center[0] + badge_radius,
            badge_center[1] + badge_radius,
        ),
        fill=green,
    )
    draw.line(
        [
            (int(size * 0.65), int(size * 0.70)),
            (int(size * 0.685), int(size * 0.735)),
            (int(size * 0.75), int(size * 0.66)),
        ],
        fill="white",
        width=int(size * 0.04),
        joint="curve",
    )
    return image


def save_resized(source: Image.Image, output: Path, size: int) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    source.resize((size, size), Image.Resampling.LANCZOS).save(output)


def main() -> None:
    BRAND_DIR.mkdir(parents=True, exist_ok=True)
    source = create_source_icon()
    source.save(SOURCE_PNG)

    for relative_path, size in ANDROID_MIPMAPS.items():
        save_resized(source, ROOT / "android" / "app" / "src" / "main" / "res" / relative_path, size)

    for filename, size in IOS_ICONS.items():
        save_resized(source, IOS_ICONSET / filename, size)

    for relative_path, size in WEB_ICONS.items():
        save_resized(source, ROOT / relative_path, size)

    print(f"Generated source icon: {SOURCE_PNG}")
    print("Updated Android, iOS, and web icons.")


if __name__ == "__main__":
    main()
