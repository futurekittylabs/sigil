#!/bin/bash
set -euo pipefail

if (( $# > 1 )); then
    echo "Usage: $0 [simulator-udid]" >&2
    exit 1
fi

app_dir="$(cd "$(dirname "$0")" && pwd)"
repo_dir="$(cd "$app_dir/../.." && pwd)"
build_dir="$repo_dir/.build/ios"
mkdir -p "$build_dir"

selection="$(xcrun simctl list devices available --json |
    xcrun swift -module-cache-path "$build_dir/SwiftModuleCache" "$app_dir/select-simulator.swift" "$@")"
read -r device_id device_state <<< "$selection"

xcodebuild -project "$app_dir/Sigil.xcodeproj" -scheme Sigil \
    -configuration Debug -destination "platform=iOS Simulator,id=$device_id" \
    -derivedDataPath "$build_dir" CODE_SIGNING_ALLOWED=NO build

if [[ "$device_state" == "Shutdown" ]]; then
    xcrun simctl boot "$device_id"
fi
xcrun simctl bootstatus "$device_id" -b
open "$(xcode-select -p)/Applications/Simulator.app" --args -CurrentDeviceUDID "$device_id"
xcrun simctl install "$device_id" "$build_dir/Build/Products/Debug-iphonesimulator/Sigil.app"
xcrun simctl launch --terminate-running-process "$device_id" dev.sigil.ios
