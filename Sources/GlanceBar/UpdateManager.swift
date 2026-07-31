import Foundation

/// Runs the source-based updater (~/.glancebar-src/update.sh), bootstrapping
/// a fresh clone when the source checkout is missing. Streams the script's
/// progress lines so the UI can show live status. On a successful install the
/// script kills this process and relaunches the new build, so `.upToDate` and
/// `.failed` are the only terminal events an alive app ever observes.
class UpdateManager {
    private final class OutputBuffer {
        private let lock = NSLock()
        private var data = Data()

        func append(_ newData: Data) {
            lock.lock()
            data.append(newData)
            lock.unlock()
        }

        func snapshot() -> Data {
            lock.lock()
            defer { lock.unlock() }
            return data
        }
    }

    enum Event {
        case status(String)
        case upToDate
        case failed(String)
    }

    /// Always invoked on the main queue.
    var onEvent: ((Event) -> Void)?
    private(set) var isRunning = false

    private var activeProcess: Process?
    private var runID: UUID?
    private var watchdogTimer: DispatchSourceTimer?
    private var overallTimer: DispatchSourceTimer?
    private let progressTimeout: TimeInterval = 5 * 60
    private let overallTimeout: TimeInterval = 30 * 60

    private let srcDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".glancebar-src")

    func runUpdate() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.runUpdate() }
            return
        }
        guard !isRunning else { return }
        isRunning = true
        let id = UUID()
        runID = id
        startTimeouts(for: id)

        let script = srcDir.appendingPathComponent("update.sh")
        if FileManager.default.fileExists(atPath: script.path) {
            runUpdateScript(script, for: id)
        } else {
            bootstrapAndUpdate(for: id)
        }
    }

    private func emitStatus(_ status: String, for id: UUID) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.runID == id else { return }
            self.resetWatchdog(for: id)
            self.onEvent?(.status(status))
        }
    }

    private func noteProgress(for id: UUID) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.runID == id else { return }
            self.resetWatchdog(for: id)
        }
    }

    private func finish(_ event: Event, for id: UUID) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard runID == id else { return }
        watchdogTimer?.cancel()
        watchdogTimer = nil
        overallTimer?.cancel()
        overallTimer = nil
        activeProcess = nil
        runID = nil
        isRunning = false
        onEvent?(event)
    }

    private func startTimeouts(for id: UUID) {
        resetWatchdog(for: id)

        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + overallTimeout)
        timer.setEventHandler { [weak self] in
            self?.timeOut(
                id,
                message: "Update timed out after 30 minutes. Please try again."
            )
        }
        overallTimer = timer
        timer.resume()
    }

    private func resetWatchdog(for id: UUID) {
        guard runID == id else { return }
        if watchdogTimer == nil {
            let timer = DispatchSource.makeTimerSource(queue: .main)
            timer.setEventHandler { [weak self] in
                self?.timeOut(
                    id,
                    message: "Update timed out after 5 minutes without progress. Please try again."
                )
            }
            timer.schedule(deadline: .now() + progressTimeout)
            watchdogTimer = timer
            timer.resume()
            return
        }
        watchdogTimer?.schedule(deadline: .now() + progressTimeout)
    }

    private func timeOut(_ id: UUID, message: String) {
        guard runID == id else { return }
        let process = activeProcess
        if process?.isRunning == true {
            process?.terminate()
        }
        finish(.failed(message), for: id)
    }

    private func runUpdateScript(_ script: URL, for id: UUID) {
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

        // Stream the script's output and forward progress lines to the banner.
        let stdoutPipe = Pipe()
        task.standardOutput = stdoutPipe
        task.standardError = stdoutPipe
        var buffer = ""
        stdoutPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            self?.noteProgress(for: id)
            guard let chunk = String(data: data, encoding: .utf8) else { return }
            buffer.append(chunk)
            while let newlineIdx = buffer.firstIndex(of: "\n") {
                let line = String(buffer[..<newlineIdx]).trimmingCharacters(in: .whitespaces)
                buffer.removeSubrange(...newlineIdx)
                if line.hasPrefix("\u{2192} ") {
                    self?.emitStatus(String(line.dropFirst(2)), for: id)
                }
            }
        }

        // On a successful install the script pkill's GlanceBar mid-run, so
        // termination is only observed for the "already up to date" path
        // (exit 0) or a failure (non-zero).
        task.terminationHandler = { [weak self] proc in
            stdoutPipe.fileHandleForReading.readabilityHandler = nil
            DispatchQueue.main.async {
                guard let self, self.runID == id, self.activeProcess === proc else { return }
                if proc.terminationStatus == 0 {
                    self.finish(.upToDate, for: id)
                } else {
                    self.finish(.failed("Update script exited with code \(proc.terminationStatus)"), for: id)
                }
            }
        }

        activeProcess = task
        do {
            try task.run()
        } catch {
            stdoutPipe.fileHandleForReading.readabilityHandler = nil
            finish(.failed("Could not start updater: \(error.localizedDescription)"), for: id)
        }
    }

    private func bootstrapAndUpdate(for id: UUID) {
        emitStatus("Cloning repo...", for: id)
        let repoURL = "https://github.com/\(AppConstants.githubRepo).git"

        // Remove any partial dir from a previous failed bootstrap.
        try? FileManager.default.removeItem(at: srcDir)

        let clone = Process()
        clone.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        clone.arguments = ["clone", "--depth", "1", repoURL, srcDir.path]
        let stderrPipe = Pipe()
        let errorOutput = OutputBuffer()
        stderrPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            errorOutput.append(data)
            self?.noteProgress(for: id)
        }
        clone.standardError = stderrPipe
        clone.standardOutput = Pipe()  // discard stdout
        clone.terminationHandler = { [weak self] proc in
            stderrPipe.fileHandleForReading.readabilityHandler = nil
            let errData = errorOutput.snapshot()
            DispatchQueue.main.async {
                guard let self, self.runID == id, self.activeProcess === proc else { return }
                if proc.terminationStatus != 0 {
                    let err = String(data: errData, encoding: .utf8)?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? "clone failed"
                    self.finish(.failed("Clone failed: \(String(err.prefix(200)))"), for: id)
                    return
                }

                let script = self.srcDir.appendingPathComponent("update.sh")
                guard FileManager.default.fileExists(atPath: script.path) else {
                    self.finish(.failed("update.sh missing from cloned repo"), for: id)
                    return
                }
                self.resetWatchdog(for: id)
                self.runUpdateScript(script, for: id)
            }
        }

        activeProcess = clone
        do {
            try clone.run()
        } catch {
            stderrPipe.fileHandleForReading.readabilityHandler = nil
            finish(.failed("git not available: \(error.localizedDescription)"), for: id)
        }
    }
}
