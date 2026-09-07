# Sigil

## Website

Requires Node.js 22.12+ (or 24+) and pnpm 12.3.4. Install [just](https://just.systems/) to use the shortcut.

```sh
pnpm install
just dev
```

`just dev` runs `pnpm --filter sigil-site dev` from the workspace root.

## Native apps

Barebones, separate SwiftUI apps for macOS and iOS, with no third-party app dependencies or storage. Each starts with Apple's `App`, `WindowGroup`, and `ContentView` template and displays “Hello, world!”.

```sh
just macos           # Build and launch on this Mac (alias: just dev-macos)
just ios             # Build and launch in Simulator (alias: just dev-ios)
just ios DEVICE_UDID # Choose a specific iPhone/iPad simulator
```

Requires macOS 26+, full Xcode with first-launch setup complete, `just`, and an iOS 26+ Simulator runtime for iOS. In Xcode Settings → Components, install an iOS runtime if needed. Run `xcrun simctl list devices available` to find device UDIDs. A developer account is unnecessary for these local Mac and Simulator runs; running on a physical iPhone requires configuring signing in Xcode.

Pre-flight verified on September 7, 2026: macOS 26.6.2, Xcode 26.6, Swift 6.3.3, iOS 26.5 SDK/runtime, just 1.51.0, and XcodeGen 2.44.1. No installs or upgrades were required. Xcode 26.6 is Apple's current stable release; Xcode 27 is beta.

Open `apps/macos/Sigil.xcodeproj` or `apps/ios/Sigil.xcodeproj` to edit, preview, and run in Xcode. Build products go into `.build/`. Projects are checked in, so XcodeGen is only needed after editing a `project.yml`:

```sh
xcodegen generate --spec apps/macos/project.yml
xcodegen generate --spec apps/ios/project.yml
```

Bootstrap references: Apple's [Create a project](https://developer.apple.com/tutorials/develop-in-swift/create-a-project) tutorial (SwiftUI, Swift, no testing system or storage), [SwiftUI App](https://developer.apple.com/documentation/swiftui/app), [Xcode system requirements](https://developer.apple.com/xcode/system-requirements/), and [Swift getting started](https://www.swift.org/getting-started/). The Swift sources follow the installed Xcode App template; XcodeGen automates project-file creation instead of using the New Project dialog.

Both native apps reference the shared Icon Composer document at `images/Sigil.icon`. See [images/README.md](images/README.md) for artwork and preview generation.
