# Sigil artwork

`Sigil.icon` is the shared, editable Icon Composer source for both native apps. The projects reference it directly from this folder; there are no platform copies to keep synchronized. Xcode compiles it with Apple's asset catalog compiler (`actool`).

The design is a calligraphic S with broad, carved strokes and a fine inward return, in warm ivory on dark aubergine. `signet-study.png` preserves the approved concept; the production artwork is the vector layer in `Sigil.icon/Assets/01-cipher.svg`.

The foreground is an outlined SVG on an unmasked 1024 × 1024 canvas. Background color, platform masking, and appearance rendering belong to Icon Composer. This keeps the artwork scalable and lets the system produce its native icon sizes and default, dark, clear, and tinted appearances.

Open `Sigil.icon` with the Icon Composer included in Xcode. To regenerate the PNG previews using Apple's `ictool`:

```sh
bash images/render.sh
```

The script exports each platform's six appearances at 1024 pixels, plus a 32-pixel default preview for checking legibility. These PNGs are review artifacts; the apps compile the native document itself.

Design references checked September 7, 2026:

- [Apple Human Interface Guidelines: App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons) — updated June 8, 2026; consistent identity across platforms, vector foreground layers, simple backgrounds, system masking, and small-size legibility.
- [Creating your app icon using Icon Composer](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer) — layered source, appearances, export, and Xcode integration.
- [Apple's Landmarks sample](https://developer.apple.com/documentation/swiftui/landmarks-building-an-app-with-liquid-glass) — reference for the native Icon Composer document structure. Sigil contains its own artwork, not the sample's artwork.

The installed Xcode 26.6 toolchain renders and builds the shipping platform behavior. Apple's current documentation also describes newer beta behavior; these assets do not depend on version 27-only controls.
