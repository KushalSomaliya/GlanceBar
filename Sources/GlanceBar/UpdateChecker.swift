import Foundation

class UpdateChecker {
    private let currentVersion: String
    private let repo: String
    private let minInterval: TimeInterval
    private var lastCheckedAt: Date?
    var onUpdateAvailable: ((String) -> Void)?

    init(currentVersion: String = AppConstants.version, repo: String = AppConstants.githubRepo, minInterval: TimeInterval = 3600) {
        self.currentVersion = currentVersion
        self.repo = repo
        self.minInterval = minInterval
    }

    func checkForUpdates() {
        if let last = lastCheckedAt, Date().timeIntervalSince(last) < minInterval { return }
        lastCheckedAt = Date()
        let urlString = "https://api.github.com/repos/\(repo)/tags?per_page=1"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self, error == nil, let data = data else { return }

            guard let tags = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                let latestTag = tags.first,
                let tagName = latestTag["name"] as? String
            else { return }

            let latest = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

            if self.isNewer(latest, than: self.currentVersion) {
                DispatchQueue.main.async {
                    self.onUpdateAvailable?(tagName)
                }
            }
        }.resume()
    }

    private func isNewer(_ remote: String, than local: String) -> Bool {
        let r = remote.split(separator: ".").compactMap { Int($0) }
        let l = local.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(r.count, l.count) {
            let rv = i < r.count ? r[i] : 0
            let lv = i < l.count ? l[i] : 0
            if rv > lv { return true }
            if rv < lv { return false }
        }
        return false
    }
}
