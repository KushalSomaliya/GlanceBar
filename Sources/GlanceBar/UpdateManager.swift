import Foundation

/// Runs the source-based updater (~/.glancebar-src/update.sh), bootstrapping
/// a fresh clone when the source checkout is missing. Streams the script's
/// progress lines so the UI can show live status. On a successful install the
/// script kills this process and relaunches the new build, so `.upToDate` and
/// `.failed` are the only terminal events an alive app ever observes.
class UpdateManager {
    enum Event {
        case status(String)
        case upToDate
        case failed(String)
    }

    /// Always invoked on the main queue.
    var onEvent: ((Event) -> Void)?
    private(set) var isRunning = false

    private let srcDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".glancebar-src")

    func runUpdate() {
        guard !isRunning else { return }
        isRunning = true

        let script = srcDir.appendingPathComponent("update.sh")
        if FileManager.default.fileExists(atPath: script.path) {
            runUpdateScript(script)
        } else {
            bootstrapAndUpdate()
        }
    }

    private func emit(_ event: Event) {
        DispatchQueue.main.async { [weak self] in
            if case .status = event {} else { self?.isRunning = false }
            self?.onEvent?(event)
        }
    }

    private func runUpdateScript(_ script: URL) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = [script.path]
        task.currentDirectoryURL = srcDir
        // Tell the script to replace the app in-place wherever the running
        // bundle lives (e.g. /Applications vs ~/Applications) so we don't
        // leave a duplicate behind.
        var env = ProcessInfo.processInfo.environment
        env["GLANCEBAR_TARGET"] = Bundle.main.bundlePath
        task.environment = env

        // Stream the script's stdout and forward progress lines to the banner.
        let stdoutPipe = Pipe()
        task.standardOutput = stdoutPipe
        var buffer = ""
        stdoutPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else { return }
            buffer.append(chunk)
            while let newlineIdx = buffer.firstIndex(of: "\n") {
                let line = String(buffer[..<newlineIdx]).trimmingCharacters(in: .whitespaces)
                buffer.removeSubrange(...newlineIdx)
                if line.hasPrefix("\u{2192} ") {
                    self?.emit(.status(String(line.dropFirst(2))))
                }
            }
        }

        // On a successful install the script pkill's GlanceBar mid-run, so
        // termination is only observed for the "already up to date" path
        // (exit 0) or a failure (non-zero).
        task.terminationHandler = { [weak self] proc in
            stdoutPipe.fileHandleForReading.readabilityHandler = nil
            if proc.terminationStatus == 0 {
                self?.emit(.upToDate)
            } else {
                self?.emit(.failed("Update script exited with code \(proc.terminationStatus)"))
            }
        }

        do {
            try task.run()
        } catch {
            stdoutPipe.fileHandleForReading.readabilityHandler = nil
            emit(.failed("Could not start updater: \(error.localizedDescription)"))
        }
    }

    private func bootstrapAndUpdate() {
        emit(.status("Cloning repo..."))

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let repoURL = "https://github.com/\(AppConstants.githubRepo).git"

            // Remove any partial dir from a previous failed bootstrap.
            try? FileManager.default.removeItem(at: self.srcDir)

            let clone = Process()
            clone.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            clone.arguments = ["clone", "--depth", "1", repoURL, self.srcDir.path]
            let stderrPipe = Pipe()
            clone.standardError = stderrPipe
            clone.standardOutput = Pipe()  // discard stdout

            do {
                try clone.run()
                clone.waitUntilExit()
            } catch {
                self.emit(.failed("git not available: \(error.localizedDescription)"))
                return
            }

            if clone.terminationStatus != 0 {
                let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let err = String(data: errData, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? "clone failed"
                self.emit(.failed("Clone failed: \(String(err.prefix(200)))"))
                return
            }

            DispatchQueue.main.async {
                let script = self.srcDir.appendingPathComponent("update.sh")
                guard FileManager.default.fileExists(atPath: script.path) else {
                    self.emit(.failed("update.sh missing from cloned repo"))
                    return
                }
                self.runUpdateScript(script)
            }
        }
    }
}
