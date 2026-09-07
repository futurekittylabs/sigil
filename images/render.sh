#!/usr/bin/env bash
set -euo pipefail

image_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
developer_dir="$(xcode-select -p)"
ictool="$developer_dir/../Applications/Icon Composer.app/Contents/Executables/ictool"
if [[ ! -x "$ictool" ]]; then
    echo "Icon Composer's ictool was not found in the selected Xcode installation." >&2
    exit 1
fi

mkdir -p "$image_dir/previews"
for platform in iOS macOS; do
    for appearance in Default Dark ClearLight ClearDark TintedLight TintedDark; do
        "$ictool" "$image_dir/Sigil.icon" --export-image \
            --output-file "$image_dir/previews/$platform-$appearance.png" \
            --platform "$platform" --rendition "$appearance" \
            --width 1024 --height 1024 --scale 1
    done
    "$ictool" "$image_dir/Sigil.icon" --export-image \
        --output-file "$image_dir/previews/$platform-32.png" \
        --platform "$platform" --rendition Default \
        --width 32 --height 32 --scale 1
done
