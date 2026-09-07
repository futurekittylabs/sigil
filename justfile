dev:
    pnpm --filter sigil-site dev

macos:
    xcodebuild -project apps/macos/Sigil-macOS.xcodeproj -scheme Sigil-macOS -configuration Debug -destination 'platform=macOS' -derivedDataPath .build/macos build
    open -n .build/macos/Build/Products/Debug/Sigil.app

ios device="iPhone 17 Pro":
    xcrun simctl bootstatus {{quote(device)}} -b
    xcodebuild -project apps/ios/Sigil-iOS.xcodeproj -scheme Sigil-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/ios build
    xcrun simctl install {{quote(device)}} .build/ios/Build/Products/Debug-iphonesimulator/Sigil.app
    open -a Simulator
    xcrun simctl launch --terminate-running-process {{quote(device)}} dev.sigil.ios
