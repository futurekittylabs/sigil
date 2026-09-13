import AppKit
import SwiftUI

struct ContentView: View {
    @State private var output = "sign your first datetime"
    @State private var signing = false
    @State private var comment: String?
    @State private var pullRequestURL: URL?

    var body: some View {
        VStack(spacing: 16) {
            Button("Sign") { Task { await signDate() } }
                .buttonStyle(.borderedProminent)
                .disabled(signing)

            Text(output)
                .foregroundStyle(output == "sign your first datetime" ? .secondary : .primary)
                .textSelection(.enabled)

            if comment != nil {
                Button("Copy & Open PR", action: copy)
            }
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
            comment = nil
        }
    }

    private func sign(_ payload: SigningPayload) async {
        await perform {
            let signed = try SecureSigner().sign(payload.message, reason: payload.reason)
            comment = SignedPayload(
                payload: payload,
                publicKey: signed.key.base64URL,
                signature: signed.signature.base64URL
            ).comment
            pullRequestURL = payload.pullRequestURL
            output = payload.action == .register ? "Signer ready" : "PR signed"
        }
    }

    private func copy() {
        guard let comment, let pullRequestURL else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(comment, forType: .string)
        NSWorkspace.shared.open(pullRequestURL)
    }

    private func perform(_ operation: () async throws -> Void) async {
        guard !signing else { return }
        signing = true
        defer { signing = false }
        do { try await operation() } catch { output = error.localizedDescription }
    }
}

#Preview { ContentView() }
