# Sigil

## Native apps

Requires macOS 26+, Xcode with an iOS 26+ Simulator runtime installed, and [just](https://just.systems/).

```sh
just macos
just ios
```

Both commands build and launch the app. `just ios` automatically boots an iPhone 17 Pro simulator. To choose another installed device, use `just ios "device name or UUID"`.

Open the projects in `apps/ios` or `apps/macos` for editing and debugging in Xcode. Source folders are synchronized automatically.

See [images](images/README.md) for the shared app icon.

## Website

Requires Node.js 22.12+ (or 24+) and pnpm 12.3.4.

```sh
pnpm install
just dev
```
