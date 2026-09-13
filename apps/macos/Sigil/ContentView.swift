import LocalAuthentication
import SwiftUI

struct ContentView: View {
    @State private var signedText: String?
    @State private var isSigning = false

    var body: some View {
        VStack(spacing: 16) {
            Button("Sign") {
                Task {
                    await sign(.dateTime(at: .now))
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSigning)

            Text(signedText ?? "sign your first datetime")
                .foregroundStyle(signedText == nil ? .secondary : .primary)
                .textSelection(.enabled)
        }
        .padding(24)
        .frame(minWidth: 360, minHeight: 160)
        .onOpenURL { url in
            guard let request = PullRequestSigningRequest(url: url) else { return }

            Task {
                await sign(.pullRequest(request))
            }
        }
    }

    private func sign(_ payload: SigningPayload) async {
        guard !isSigning else { return }

        isSigning = true
        defer { isSigning = false }

        let context = LAContext()
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

        guard context.canEvaluatePolicy(policy, error: nil) else { return }

        guard let authenticated = try? await context.evaluatePolicy(
            policy,
            localizedReason: payload.authenticationReason
        ),
              authenticated else { return }

        signedText = payload.signedText
    }
}

#Preview {
    ContentView()
}
