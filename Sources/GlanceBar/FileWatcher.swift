import Foundation

class FileWatcher {
    private var fileDescriptor: Int32 = -1
    private var source: DispatchSourceFileSystemObject?
    private var debounceWorkItem: DispatchWorkItem?
    private let filePath: String
    private let onChange: () -> Void
    private var retryTimer: DispatchWorkItem?

    init(filePath: String, onChange: @escaping () -> Void) {
        self.filePath = filePath
        self.onChange = onChange
    }

    func start() {
        watch()
    }

    func stop() {
        stopCurrentSource()
        retryTimer?.cancel()
        retryTimer = nil
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
    }

    private func watch() {
        stopCurrentSource()

        fileDescriptor = open(filePath, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            retryAfterDelay()
            return
        }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename, .attrib],
            queue: .main
        )

        source?.setEventHandler { [weak self] in
            guard let self else { return }
            let flags = self.source?.data ?? []

            if flags.contains(.delete) || flags.contains(.rename) {
                // Atomic save: editor wrote to temp file and renamed
                self.stopCurrentSource()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.watch()
                    self?.debouncedReload()
                }
            } else if flags.contains(.write) || flags.contains(.attrib) {
                self.debouncedReload()
            }
        }

        source?.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd >= 0 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }

        source?.resume()
    }

    private func debouncedReload() {
        debounceWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.onChange()
        }
        debounceWorkItem = item
        DispatchQueue.main.asyncAfter(
            deadline: .now() + AppConstants.fileReloadDebounce, execute: item)
    }

    private func stopCurrentSource() {
        source?.cancel()
        source = nil
    }

    private func retryAfterDelay() {
        retryTimer?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.watch()
        }
        retryTimer = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: item)
    }
}
