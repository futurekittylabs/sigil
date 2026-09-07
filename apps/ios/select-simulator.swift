import Foundation

struct DeviceList: Decodable {
    let devices: [String: [Device]]
}

struct Device: Decodable {
    let udid: String
    let name: String
    let state: String
    let isAvailable: Bool
    let deviceTypeIdentifier: String
}

do {
    let requestedID = CommandLine.arguments.dropFirst().first.flatMap { $0.isEmpty ? nil : $0 }
    let list = try JSONDecoder().decode(
        DeviceList.self,
        from: FileHandle.standardInput.readDataToEndOfFile()
    )
    let devices = list.devices.keys.sorted {
        $0.localizedStandardCompare($1) == .orderedDescending
    }.filter { runtime in
        let prefix = "com.apple.CoreSimulator.SimRuntime.iOS-"
        guard runtime.hasPrefix(prefix),
              let major = Int(runtime.dropFirst(prefix.count).split(separator: "-")[0])
        else { return false }
        return major >= 26
    }.flatMap { list.devices[$0, default: []] }.filter { device in
        device.isAvailable && (requestedID.map {
            device.udid.caseInsensitiveCompare($0) == .orderedSame
        } ?? device.deviceTypeIdentifier.contains(".iPhone-"))
    }

    guard let device = devices.first(where: { $0.state == "Booted" }) ?? devices.first else {
        throw NSError(domain: "Sigil", code: 1, userInfo: [
            NSLocalizedDescriptionKey: requestedID == nil
                ? "No available iPhone simulator running iOS 26 or later. Install one in Xcode Settings > Components."
                : "The requested simulator is unavailable or does not run iOS 26 or later."
        ])
    }
    FileHandle.standardError.write(Data("Using \(device.name) (\(device.udid)).\n".utf8))
    print("\(device.udid) \(device.state)")
} catch {
    FileHandle.standardError.write(Data("Simulator selection failed: \(error.localizedDescription)\n".utf8))
    exit(1)
}
