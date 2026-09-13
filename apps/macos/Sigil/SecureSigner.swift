import CryptoKit
import LocalAuthentication
import Security

struct SecureSigner {
    private let service = "dev.sigil.signing-key"

    func sign(_ message: Data, reason: String) throws -> (key: Data, signature: Data) {
        let context = LAContext()
        context.localizedReason = reason
        let key = try key(context)
        return (key.publicKey.x963Representation, try key.signature(for: message).derRepresentation)
    }

    private func key(_ context: LAContext) throws -> SecureEnclave.P256.Signing.PrivateKey {
        var item: CFTypeRef?
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecReturnData: true,
        ] as CFDictionary

        if SecItemCopyMatching(query, &item) == errSecSuccess, let data = item as? Data {
            return try SecureEnclave.P256.Signing.PrivateKey(
                dataRepresentation: data,
                authenticationContext: context
            )
        }

        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, .biometryCurrentSet],
            nil
        )!
        let key = try SecureEnclave.P256.Signing.PrivateKey(
            accessControl: access,
            authenticationContext: context
        )
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData: key.dataRepresentation,
        ] as CFDictionary, nil)
        guard status == errSecSuccess else { throw CocoaError(.fileWriteUnknown) }
        return key
    }
}
