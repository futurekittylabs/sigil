dev:
    pnpm --filter sigil-site dev

# Build and launch the native macOS app.
alias macos := dev-macos
dev-macos:
    bash apps/macos/run.sh

# Build and launch the iOS app in Simulator (optionally specify a device UDID).
alias ios := dev-ios
dev-ios device="":
    bash apps/ios/run.sh {{quote(device)}}
