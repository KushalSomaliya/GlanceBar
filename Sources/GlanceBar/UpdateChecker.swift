import Foundation

enum UpdateStatus {
    /// remoteCommit is origin/main's HEAD when known — used to remember dismissals.
    case updateAvailable(remoteCommit: String?, summary: String)
    case upToDate
    case checkFailed(String)
}

/// Decides whether an update is available. The updater installs origin/main
/// (git pull + rebuild), so the check compares the commit this binary was
/// built from against origin/main via the GitHub compare API — the same
/// source of truth the installer uses. Binaries without a build-commit stamp
/// (pre-1.1.3 installs) fall back to comparing semver tags against the
/// compiled-in version string.
class UpdateChecker {
    private let currentVersion: String
    private let repo: String
    private let minInterval: TimeInterval
    private let buildCommit: String?
    private let buildDirty: Bool
    private var lastCheckedAt: Date?

    init(
        currentVersion: String = AppConstants.version,
        repo: String = AppConstants.githubRepo,
        minInterval: TimeInterval = 3600,
        buildCommit: String? = AppConstants.buildCommit,
        buildDirty: Bool = Bundle.main.object(forInfoDictionaryKey: "GlanceBarBuildDirty") as? Bool ?? false
    ) {
        self.currentVersion = currentVersion
        self.repo = repo
        self.minInterval = minInterval
        self.buildCommit = buildCommit
        self.buildDirty = buildDirty
    }

    /// `force` bypasses the debounce (user picked "Check for Updates…").
    /// Completion runs on the main queue. Debounced auto-checks and
    /// inconclusive commit fallbacks return without calling completion.
    func checkForUpdates(force: Bool = false, completion: @escaping (UpdateStatus) -> Void) {
        if !force, let last = lastCheckedAt, Date().timeIntervalSince(last) < minInterval { return }
        lastCheckedAt = Date()

        if buildDirty {
            DispatchQueue.main.async { completion(.upToDate) }
            return
        }

        if let built = buildCommit {
            compareBuildCommit(built, completion: completion)
        } else {
            compareTags(completion: completion)
        }
    }

    // MARK: - Commit comparison (stamped builds)

    private func compareBuildCommit(_ built: String, completion: @escaping (UpdateStatus) -> Void) {
        let urlString = "https://api.github.com/repos/\(repo)/compare/\(built)...main"
        fetchJSON(urlString) { result in
            switch result {
            case .failure(let message, let httpStatus):
                if httpStatus == 404 {
                    self.compareTags(silentIfInconclusive: true, completion: completion)
                } else {
                    completion(.checkFailed(message))
                }
            case .success(let json):
                guard let dict = json as? [String: Any],
                    let status = dict["status"] as? String
                else {
                    completion(.checkFailed("Unexpected response from GitHub"))
                    return
                }
                switch status {
                case "ahead", "diverged":
                    let remoteCommit = ((dict["commits"] as? [[String: Any]])?.last?["sha"] as? String)
                    let aheadBy = dict["ahead_by"] as? Int ?? 0
                    let summary = aheadBy == 1 ? "1 new update available" : "\(max(aheadBy, 1)) new updates available"
                    completion(.updateAvailable(remoteCommit: remoteCommit, summary: summary))
                default:  // "identical" or "behind" (local is newer)
                    completion(.upToDate)
                }
            }
        }
    }

    // MARK: - Tag comparison (fallback for unstamped binaries)

    private func compareTags(
        silentIfInconclusive: Bool = false,
        completion: @escaping (UpdateStatus) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(repo)/tags?per_page=100"
        fetchJSON(urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let message, _):
                if !silentIfInconclusive { completion(.checkFailed(message)) }
            case .success(let json):
                guard let tags = json as? [[String: Any]] else {
                    if !silentIfInconclusive {
                        completion(.checkFailed("Unexpected response from GitHub"))
                    }
                    return
                }
                // The tags endpoint has no ordering guarantee — pick the
                // semver maximum ourselves.
                var latest: (components: [Int], name: String, sha: String?)?
                for tag in tags {
                    guard let name = tag["name"] as? String else { continue }
                    let components = Self.versionComponents(name)
                    guard !components.isEmpty else { continue }
                    if latest == nil || Self.compare(components, latest!.components) > 0 {
                        latest = (components, name, (tag["commit"] as? [String: Any])?["sha"] as? String)
                    }
                }
                guard let latest else {
                    if !silentIfInconclusive { completion(.upToDate) }
                    return
                }
                if Self.compare(latest.components, Self.versionComponents(self.currentVersion)) > 0 {
                    completion(.updateAvailable(remoteCommit: latest.sha, summary: "GlanceBar \(latest.name) is available"))
                } else {
                    completion(.upToDate)
                }
            }
        }
    }

    static func versionComponents(_ version: String) -> [Int] {
        var v = version
        if v.hasPrefix("v") { v = String(v.dropFirst()) }
        // "1.2.0-beta" → [1, 2, 0]; non-numeric tags → [] (skipped)
        let numericPart = v.split(separator: "-").first.map(String.init) ?? v
        let parts = numericPart.split(separator: ".").map { Int($0) }
        guard parts.allSatisfy({ $0 != nil }) else { return [] }
        return parts.compactMap { $0 }
    }

    static func compare(_ a: [Int], _ b: [Int]) -> Int {
        for i in 0..<max(a.count, b.count) {
            let av = i < a.count ? a[i] : 0
            let bv = i < b.count ? b[i] : 0
            if av != bv { return av > bv ? 1 : -1 }
        }
        return 0
    }

    // MARK: - Networking

    private enum FetchResult {
        case success(Any)
        case failure(String, httpStatus: Int?)
    }

    private func fetchJSON(_ urlString: String, completion: @escaping (FetchResult) -> Void) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion(.failure("Bad URL", httpStatus: nil)) }
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            let finish: (FetchResult) -> Void = { result in
                DispatchQueue.main.async { completion(result) }
            }
            if let error {
                finish(.failure(error.localizedDescription, httpStatus: nil))
                return
            }
            let httpStatus = (response as? HTTPURLResponse)?.statusCode
            guard let httpStatus, (200..<300).contains(httpStatus) else {
                finish(.failure("GitHub returned HTTP \(httpStatus ?? -1)", httpStatus: httpStatus))
                return
            }
            guard let data, let json = try? JSONSerialization.jsonObject(with: data) else {
                finish(.failure("Could not parse GitHub response", httpStatus: httpStatus))
                return
            }
            finish(.success(json))
        }.resume()
    }
}
