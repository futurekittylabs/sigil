dev:
    pnpm --filter sigil-site dev

build:
    xcodebuild -quiet -project apps/macos/Sigil-macOS.xcodeproj -scheme Sigil-macOS \
        -configuration Release -derivedDataPath .build/macos build
    rm -rf /Applications/Sigil.app
    ditto .build/macos/Build/Products/Release/Sigil.app /Applications/Sigil.app

macos:
    xcodebuild -project apps/macos/Sigil-macOS.xcodeproj -scheme Sigil-macOS \
        -derivedDataPath .build/macos
    open -n .build/macos/Build/Products/Debug/Sigil.app

ios device="iPhone 17 Pro":
    xcrun simctl bootstatus {{quote(device)}} -b
    xcodebuild -project apps/ios/Sigil-iOS.xcodeproj -scheme Sigil-iOS \
        -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/ios
    xcrun simctl install {{quote(device)}} .build/ios/Build/Products/Debug-iphonesimulator/Sigil.app
    open -a Simulator
    xcrun simctl launch --terminate-running-process {{quote(device)}} dev.sigil.ios
