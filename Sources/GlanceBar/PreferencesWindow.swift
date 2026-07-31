import SwiftUI

struct PreferencesView: View {
    let preferences: PreferencesManager
    var onThemeChanged: (() -> Void)?
    var onShortcutChanged: (() -> Void)?

    @State private var selectedCorner: ScreenCorner
    @State private var panelWidth: Double
    @State private var launchAtLogin: Bool
    @State private var widgetPath: String
    @State private var widgetPathError: String?
    @State private var selectedTheme: String
    @State private var shortcutDisplay: String
    @State private var isRecording = false
    @State private var keyMonitor: Any?
    @FocusState private var isWidgetPathFocused: Bool

    init(preferences: PreferencesManager, onThemeChanged: (() -> Void)? = nil, onShortcutChanged: (() -> Void)? = nil) {
        self.preferences = preferences
        self.onThemeChanged = onThemeChanged
        self.onShortcutChanged = onShortcutChanged
        _selectedCorner = State(initialValue: preferences.hotCorner)
        _panelWidth = State(initialValue: Double(preferences.panelWidth))
        _launchAtLogin = State(initialValue: preferences.launchAtLogin)
        _widgetPath = State(initialValue: preferences.widgetFilePath)
        _widgetPathError = State(initialValue: nil)
        _selectedTheme = State(initialValue: preferences.theme)
        _shortcutDisplay = State(initialValue: preferences.shortcutDisplayString)
    }

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $selectedTheme) {
                    Text("Auto (System)").tag("auto")
                    Text("Dark").tag("dark")
                    Text("Light").tag("light")
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedTheme) { _, newValue in
                    preferences.theme = newValue
                    onThemeChanged?()
                }
            }

            Section("Keyboard Shortcut") {
                HStack {
                    Text("Toggle Panel")
                    Spacer()
                    Button(action: { toggleRecording() }) {
                        Text(isRecording ? "Press keys..." : shortcutDisplay)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(isRecording ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                            .cornerRadius(6)
                            .foregroundStyle(isRecording ? .blue : .primary)
                            .font(.system(size: 12, weight: .medium, design: isRecording ? .default : .monospaced))
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    Button("Clear Shortcut") {
                        stopRecording()
                        preferences.shortcutKey = ""
                        preferences.shortcutKeyCode = nil
                        shortcutDisplay = "None"
                        onShortcutChanged?()
                    }
                    .font(.caption)
                    Spacer()
                    Text("Click shortcut to re-record")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Hot Corner") {
                Picker("Activation Corner", selection: $selectedCorner) {
                    ForEach(ScreenCorner.allCases, id: \.self) { corner in
                        Text(corner.displayName).tag(corner)
                    }
                }
                .onChange(of: selectedCorner) { _, newValue in
                    preferences.hotCorner = newValue
                }
                Text("Move your mouse to this corner to open the widget panel")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Panel") {
                HStack {
                    Text("Width: \(Int(panelWidth))px")
                    Slider(value: $panelWidth, in: 280...600, step: 10)
                        .onChange(of: panelWidth) { _, newValue in
                            preferences.panelWidth = newValue
                        }
                }
            }

            Section("Widget File") {
                TextField("Path", text: $widgetPath)
                    .focused($isWidgetPathFocused)
                    .onSubmit { commitWidgetPath() }
                    .onChange(of: isWidgetPathFocused) { _, isFocused in
                        if !isFocused { commitWidgetPath() }
                    }
                if let widgetPathError {
                    Text(widgetPathError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                HStack {
                    Button("Open in Editor") {
                        commitWidgetPath()
                        let url = URL(fileURLWithPath: preferences.widgetFilePath)
                        NSWorkspace.shared.open(url)
                    }
                    Button("Reveal in Finder") {
                        commitWidgetPath()
                        let url = URL(fileURLWithPath: preferences.widgetFilePath)
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                }
            }

            Section("General") {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        preferences.launchAtLogin = newValue
                    }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 540)
        .onAppear {
            widgetPath = preferences.widgetFilePath
            widgetPathError = nil
        }
        .onDisappear { stopRecording() }
    }

    private func commitWidgetPath() {
        guard widgetPath != preferences.widgetFilePath else {
            widgetPathError = nil
            return
        }

        var isDirectory: ObjCBool = false
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: widgetPath, isDirectory: &isDirectory),
            !isDirectory.boolValue,
            fileManager.isReadableFile(atPath: widgetPath)
        else {
            widgetPathError = "Choose an existing, readable file. The current widget is still in use."
            return
        }

        widgetPathError = nil
        preferences.widgetFilePath = widgetPath
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Escape = cancel
            if event.keyCode == 53 {
                stopRecording()
                return nil
            }
            // Delete = clear
            if event.keyCode == 51 || event.keyCode == 117 {
                stopRecording()
                preferences.shortcutKey = ""
                preferences.shortcutKeyCode = nil
                shortcutDisplay = "None"
                onShortcutChanged?()
                return nil
            }
            let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                .subtracting(NSEvent.ModifierFlags.capsLock)
                .subtracting(NSEvent.ModifierFlags.numericPad)
                .subtracting(NSEvent.ModifierFlags.function)
            let hasModifier = mods.contains(NSEvent.ModifierFlags.command) ||
                              mods.contains(NSEvent.ModifierFlags.control) ||
                              mods.contains(NSEvent.ModifierFlags.option)
            if hasModifier, let chars = event.charactersIgnoringModifiers, !chars.isEmpty {
                preferences.shortcutKey = chars
                preferences.shortcutKeyCode = Int(event.keyCode)
                preferences.shortcutModifiers = mods
                shortcutDisplay = preferences.shortcutDisplayString
                onShortcutChanged?()
                stopRecording()
            }
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let m = keyMonitor {
            NSEvent.removeMonitor(m)
            keyMonitor = nil
        }
    }
}
