import SwiftUI

struct PreferencesView: View {
    let preferences: PreferencesManager
    var onThemeChanged: (() -> Void)?

    @State private var selectedCorner: ScreenCorner
    @State private var panelWidth: Double
    @State private var launchAtLogin: Bool
    @State private var widgetPath: String
    @State private var selectedTheme: String

    init(preferences: PreferencesManager, onThemeChanged: (() -> Void)? = nil) {
        self.preferences = preferences
        self.onThemeChanged = onThemeChanged
        _selectedCorner = State(initialValue: preferences.hotCorner)
        _panelWidth = State(initialValue: Double(preferences.panelWidth))
        _launchAtLogin = State(initialValue: preferences.launchAtLogin)
        _widgetPath = State(initialValue: preferences.widgetFilePath)
        _selectedTheme = State(initialValue: preferences.theme)
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
                    .onChange(of: widgetPath) { _, newValue in
                        preferences.widgetFilePath = newValue
                    }
                HStack {
                    Button("Open in Editor") {
                        let url = URL(fileURLWithPath: preferences.widgetFilePath)
                        NSWorkspace.shared.open(url)
                    }
                    Button("Reveal in Finder") {
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
        .frame(width: 420, height: 450)
    }
}
