import Foundation

enum SigningPayload {
    case dateTime(String)
    case pullRequest(PullRequestSigningRequest)

    static func dateTime(at date: Date) -> Self {
        .dateTime(date.formatted(date: .abbreviated, time: .complete))
    }

    var authenticationReason: String {
        switch self {
        case .dateTime(let dateTime):
            "Sign this datetime?\n\(dateTime)"
        case .pullRequest(let request):
            "Sign this PR?\n\(request.pullRequestURL.absoluteString)\nCommit \(request.commit)"
        }
    }

    var signedText: String {
        switch self {
        case .dateTime(let dateTime):
            "Signed \(dateTime)"
        case .pullRequest(let request):
            "Signed \(request.pullRequestURL.absoluteString)\nCommit \(request.commit)"
        }
    }
}

struct PullRequestSigningRequest {
    let repository: String
    let pullRequestURL: URL
    let commit: String

    init?(url: URL) {
        guard url.scheme == "sigil", url.host == "sign", url.path.isEmpty,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems,
              items.count == 3,
              let repository = Self.value(named: "repository", in: items),
              let pullRequest = Self.value(named: "pull_request", in: items),
              let commit = Self.value(named: "commit", in: items),
              Self.isValid(repository: repository),
              Self.isValid(commit: commit),
              let pullRequestURL = URL(string: pullRequest),
              Self.isValid(pullRequestURL: pullRequestURL, repository: repository) else {
            return nil
        }

        self.repository = repository
        self.pullRequestURL = pullRequestURL
        self.commit = commit
    }

    private static func value(named name: String, in items: [URLQueryItem]) -> String? {
        let matches = items.filter { $0.name == name }
        guard matches.count == 1, let value = matches[0].value, !value.isEmpty else {
            return nil
        }
        return value
    }

    private static func isValid(repository: String) -> Bool {
        let parts = repository.split(separator: "/", omittingEmptySubsequences: false)
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")

        return parts.count == 2 && parts.allSatisfy { part in
            !part.isEmpty && part.count <= 100 && part.unicodeScalars.allSatisfy(allowed.contains)
        }
    }

    private static func isValid(commit: String) -> Bool {
        let hexadecimal = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        return commit.count == 40 && commit.unicodeScalars.allSatisfy(hexadecimal.contains)
    }

    private static func isValid(pullRequestURL: URL, repository: String) -> Bool {
        guard let components = URLComponents(url: pullRequestURL, resolvingAgainstBaseURL: false),
              components.scheme == "https",
              components.host == "github.com",
              components.user == nil,
              components.password == nil,
              components.port == nil,
              components.query == nil,
              components.fragment == nil else {
            return false
        }

        let repositoryParts = repository.split(separator: "/")
        let pathParts = components.path.split(separator: "/")

        return pathParts.count == 4
            && pathParts[0].caseInsensitiveCompare(repositoryParts[0]) == .orderedSame
            && pathParts[1].caseInsensitiveCompare(repositoryParts[1]) == .orderedSame
            && pathParts[2] == "pull"
            && Int(pathParts[3]).map { $0 > 0 } == true
    }
}
