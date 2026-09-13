import AppKit
import SwiftUI

struct ContentView: View {
    @State private var output = "sign your first datetime"
    @State private var signing = false

    var body: some View {
        VStack(spacing: 16) {
            Button("Sign") { Task { await signDate() } }
                .buttonStyle(.borderedProminent)
                .disabled(signing)

            Text(output)
                .foregroundStyle(output == "sign your first datetime" ? .secondary : .primary)
                .textSelection(.enabled)
        }
        .padding(24)
        .frame(minWidth: 360, minHeight: 160)
        .onOpenURL { url in
            guard let payload = SigningPayload(url: url) else { return }
            Task { await sign(payload) }
        }
    }

    private func signDate() async {
        let value = Date.now.formatted(date: .abbreviated, time: .complete)
        await perform {
            _ = try SecureSigner().sign(Data(value.utf8), reason: "Sign this datetime?\n\(value)")
            output = "Signed \(value)"
        }
    }

    private func sign(_ payload: SigningPayload) async {
        await perform {
            let signed = try SecureSigner().sign(payload.message, reason: payload.reason)
            var request = URLRequest(url: URL(string: "https://sigil.fklabs.workers.dev/sign")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(SignedPayload(
                payload: payload,
                publicKey: signed.key.base64URL,
                signature: signed.signature.base64URL
            ))
            let (_, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 204 else {
                throw URLError(.badServerResponse)
            }
            output = payload.action == .register ? "Signer registered" : "PR signed"
            NSWorkspace.shared.open(payload.pullRequestURL)
        }
    }

    private func perform(_ operation: () async throws -> Void) async {
        guard !signing else { return }
        signing = true
        defer { signing = false }
        do { try await operation() } catch { output = error.localizedDescription }
    }
}

#Preview { ContentView() }
