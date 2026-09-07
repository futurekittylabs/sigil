# Sigil

## Native apps

Requires macOS 26+, Xcode with an iOS 26+ Simulator runtime installed, and [just](https://just.systems/).

```sh
just macos
just ios
```

Both commands build and launch the app. `just ios` automatically boots an iPhone 17 Pro simulator. To choose another installed device, use `just ios "device name or UUID"`.

Projects are checked in. After editing a `project.yml`, regenerate with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
xcodegen generate --spec apps/macos/project.yml
xcodegen generate --spec apps/ios/project.yml
```

See [images](images/README.md) for the shared app icon.

## Website

Requires Node.js 22.12+ (or 24+) and pnpm 12.3.4.

```sh
pnpm install
just dev
```
