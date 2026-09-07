#!/usr/bin/env bash
set -euo pipefail

app_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$app_dir/../.." && pwd)"
build_dir="$repo_dir/.build/macos"

xcodebuild \
  -project "$app_dir/Sigil.xcodeproj" \
  -scheme Sigil \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath "$build_dir" \
  build

open "$build_dir/Build/Products/Debug/Sigil.app"
