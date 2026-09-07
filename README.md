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
just macos       # Build and launch a fresh macOS app instance
just ios         # Build and run on an already booted iOS Simulator
just ios <UDID>  # Boot a specific simulator, then build and run
```

For iOS, open Simulator and boot a device first, or find a device UUID with `xcrun simctl list devices available` and pass it to `just ios`. Use a UUID when multiple simulators are booted.

Requires macOS 26+, full Xcode with first-launch setup complete, `just`, and an iOS 26+ Simulator runtime for iOS. In Xcode Settings → Components, install an iOS runtime if needed. A developer account is unnecessary for these local Mac and Simulator runs; running on a physical iPhone requires configuring signing in Xcode.

Pre-flight verified on September 7, 2026: macOS 26.6.2, Xcode 26.6, Swift 6.3.3, iOS 26.5 SDK/runtime, just 1.51.0, and XcodeGen 2.44.1. No installs or upgrades were required. Xcode 26.6 is Apple's current stable release; Xcode 27 is beta.

`just macos` and `just ios` use `xcodebuild` with the checked-in projects and schemes, then Apple's `open` or `simctl` commands to launch. Xcode's UI does not need to be open. Build products go into the ignored `.build/macos` and `.build/ios` directories. All commands live directly in the justfile; there are no custom launch scripts or simulator selection code. `just dev-macos` and `just dev-ios` are equivalent aliases.

The projects and shared schemes are named `Sigil-macOS` and `Sigil-iOS`; both app products are named Sigil. The CLI recipes build Debug and launch without attaching a debugger. For interactive debugging, `just xcode` opens the projects; select a scheme and destination and press ⌘R. Scheme Run arguments and environment variables apply to Xcode launches, not these standalone launches. For Simulator launch environment variables, use Apple's `SIMCTL_CHILD_` prefix, for example `SIMCTL_CHILD_MY_SETTING=value just ios <UDID>`.

`project.yml` is XcodeGen's project-generation format, not an Apple runtime configuration. The generated `.xcodeproj` and shared `.xcscheme` files are checked in and used directly by Apple's tools. If you edit a `project.yml`, regenerate its project:

```sh
xcodegen generate --spec apps/macos/project.yml
xcodegen generate --spec apps/ios/project.yml
```

Bootstrap references: Apple's [Create a project](https://developer.apple.com/tutorials/develop-in-swift/create-a-project) tutorial (SwiftUI, Swift, no testing system or storage), [SwiftUI App](https://developer.apple.com/documentation/swiftui/app), [Xcode system requirements](https://developer.apple.com/xcode/system-requirements/), and [Swift getting started](https://www.swift.org/getting-started/). The Swift sources follow the installed Xcode App template; XcodeGen automates project-file creation instead of using the New Project dialog.

Apple workflow references: [Running your app](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices), [shared build schemes](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project), and [Xcode command-line tools](https://developer.apple.com/documentation/xcode/xcode-command-line-tool-reference). `man xcodebuild`, `xcrun simctl help`, and `man open` document the installed CLI options.

Both native apps reference the shared Icon Composer document at `images/Sigil.icon`. See [images/README.md](images/README.md) for artwork and preview generation.
