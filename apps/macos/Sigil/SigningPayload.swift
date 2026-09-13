import Foundation

struct SigningPayload: Codable {
    enum Action: String, Codable {
        case register
        case sign
    }

    let action: Action
    let repository: String
    let pullRequest: Int
    let commit: String
    let expiresAt: Int

    enum CodingKeys: String, CodingKey {
        case action, repository, commit
        case pullRequest = "pull_request"
        case expiresAt = "expires_at"
    }

    init?(url: URL) {
        guard url.scheme == "sigil", url.host == "sign",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              items.count == 4,
              Set(items.map(\.name)).count == 4,
              let actionValue = items.first(where: { $0.name == "action" })?.value,
              let action = Action(rawValue: actionValue),
              let repository = items.first(where: { $0.name == "repository" })?.value,
              repository.range(of: "^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", options: .regularExpression) != nil,
              let number = items.first(where: { $0.name == "pull_request" })?.value,
              let pullRequest = Int(number), pullRequest > 0,
              let commit = items.first(where: { $0.name == "commit" })?.value,
              commit.range(of: "^[0-9a-f]{40}$", options: .regularExpression) != nil else {
            return nil
        }
        self.action = action
        self.repository = repository
        self.pullRequest = pullRequest
        self.commit = commit
        expiresAt = Int(Date.now.timeIntervalSince1970) + 300
    }

    var message: Data {
        Data("sigil/v1\n\(action.rawValue)\n\(repository)\n\(pullRequest)\n\(commit)\n\(expiresAt)".utf8)
    }

    var reason: String {
        "\(action == .register ? "Register signer for" : "Sign") \(repository)#\(pullRequest)?\nCommit \(commit)"
    }

    var pullRequestURL: URL {
        URL(string: "https://github.com/\(repository)/pull/\(pullRequest)")!
    }
}

struct SignedPayload: Encodable {
    let payload: SigningPayload
    let publicKey: String
    let signature: String

    enum CodingKeys: String, CodingKey {
        case payload, signature
        case publicKey = "public_key"
    }
}

extension Data {
    var base64URL: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
