import CryptoKit
import Foundation

/// Keeps the app-generated widget HTML current across app updates.
///
/// The widget file is user-editable, so it can never be blindly overwritten.
/// Instead, a sidecar file records the hash of the default the app last
/// wrote; if the widget file still matches that hash (or the hash of any
/// default a previous app version shipped), it is an unmodified app-generated
/// file and safe to regenerate. Anything else is user-customized and is left
/// untouched.
enum WidgetTemplate {
    /// SHA-256 of every default widget HTML this app has ever generated,
    /// extracted from the git history of DefaultWidget.swift. Lets installs
    /// that predate the sidecar file (≤ v1.1.2) refresh safely.
    private static let knownDefaultHashes: Set<String> = [
        "073fec2d8af954cb55bec60cb4e1f982ae8426a882bf48b2bbc022e055bb217a",  // initial commit
        "626e6bb43a676ec91771d9ffd574451268567f383d7c1ebf1b3847732efc20b5",  // multi-page tabs
        "c1703f45952109d6ba18d9fa507dd71c51a098982c833b6ec12e406e33356d88",  // global hotkey / inline editing
        "31850c87884d9041716ff3c297e0ae01913545625c54687134c427f9bf39f4dc",  // install script / update checker
        "31cb573344fd6526910e05aa65056d81907f04a49abc2b759eb5eb3d682d37ed",  // recently copied card
        "036dc313e1abf2a6518abaa32cc62292e32e1221c04bf55bfe076a609841e71f",  // text contrast / tooltips
        "3ac8182680a3b2a6f590463805b192af90a215c1113011c5fe0a0f0ed6bd845e",  // action entries (v1.1.0)
        "04bff2a56d18fa173dd1893613b52026a17ce6efb59497af005c29567eb58bea",  // in-app updater (v1.1.2)
        "f2f9831c7cfe8c9c9fa2f51cc097eba94cf79a4ae3137561f50c3224b24c54d6",  // launch entries (pre-1.1.3 dev)
    ]

    private static var sidecarURL: URL {
        AppConstants.defaultWidgetDirectory.appendingPathComponent(".default-widget-sha256")
    }

    /// Ensures the widget file exists and, when it is an unmodified
    /// app-generated default, refreshes it to the current template (backing
    /// up the old file next to it first).
    static func ensureCurrent(at path: String) {
        let fm = FileManager.default
        let fileURL = URL(fileURLWithPath: path)
        let template = DefaultWidget.html
        let templateHash = sha256Hex(Data(template.utf8))

        guard fm.fileExists(atPath: path) else {
            writeTemplate(template, to: fileURL, hash: templateHash)
            return
        }
        guard let existingData = try? Data(contentsOf: fileURL) else { return }
        let existingHash = sha256Hex(existingData)

        if existingHash == templateHash {
            // Already current — make sure the sidecar reflects it.
            try? templateHash.write(to: sidecarURL, atomically: true, encoding: .utf8)
            return
        }

        let sidecarHash = (try? String(contentsOf: sidecarURL, encoding: .utf8))?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let isUnmodifiedDefault = existingHash == sidecarHash || knownDefaultHashes.contains(existingHash)
        guard isUnmodifiedDefault else { return }

        let backupURL = fileURL.deletingLastPathComponent()
            .appendingPathComponent(fileURL.lastPathComponent + ".bak")
        try? fm.removeItem(at: backupURL)
        try? fm.copyItem(at: fileURL, to: backupURL)
        writeTemplate(template, to: fileURL, hash: templateHash)
    }

    private static func writeTemplate(_ html: String, to url: URL, hash: String) {
        try? html.write(to: url, atomically: true, encoding: .utf8)
        try? hash.write(to: sidecarURL, atomically: true, encoding: .utf8)
    }

    private static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
