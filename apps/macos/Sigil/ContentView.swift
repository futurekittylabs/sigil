import LocalAuthentication
import SwiftUI

struct ContentView: View {
    @State private var signedDateTime: String?
    @State private var isSigning = false

    var body: some View {
        VStack(spacing: 16) {
            Button("Sign") {
                Task {
                    await sign()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSigning)

            Text(signedDateTime.map { "Signed \($0)" } ?? "sign your first datetime")
                .foregroundStyle(signedDateTime == nil ? .secondary : .primary)
                .textSelection(.enabled)
        }
        .padding(24)
        .frame(minWidth: 360, minHeight: 160)
    }

    private func sign() async {
        isSigning = true
        defer { isSigning = false }

        let dateTime = Date.now.formatted(date: .abbreviated, time: .complete)
        let context = LAContext()
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

        guard context.canEvaluatePolicy(policy, error: nil) else { return }

        let reason = "Sign this datetime?\n\(dateTime)"
        guard let authenticated = try? await context.evaluatePolicy(policy, localizedReason: reason),
              authenticated else { return }

        signedDateTime = dateTime
    }
}

#Preview {
    ContentView()
}
