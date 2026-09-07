dev:
    pnpm --filter sigil-site dev

# Optional: open the projects for editing and interactive debugging.
xcode:
    xcrun xed apps/macos/Sigil-macOS.xcodeproj apps/ios/Sigil-iOS.xcodeproj

# Build and launch a fresh instance of the macOS app.
alias macos := dev-macos
dev-macos:
    xcodebuild -project apps/macos/Sigil-macOS.xcodeproj -scheme Sigil-macOS -configuration Debug -destination 'platform=macOS' -derivedDataPath .build/macos build
    open -n .build/macos/Build/Products/Debug/Sigil.app

alias ios := dev-ios
dev-ios device="iPhone 17 Pro":
    xcrun simctl bootstatus {{quote(device)}} -b
    xcodebuild -project apps/ios/Sigil-iOS.xcodeproj -scheme Sigil-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/ios build
    xcrun simctl install {{quote(device)}} .build/ios/Build/Products/Debug-iphonesimulator/Sigil.app
    open -a Simulator
    xcrun simctl launch --terminate-running-process {{quote(device)}} dev.sigil.ios
