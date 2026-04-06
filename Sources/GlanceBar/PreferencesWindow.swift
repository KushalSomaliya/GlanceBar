import SwiftUI

struct PreferencesView: View {
    let preferences: PreferencesManager
    @State private var selectedCorner: ScreenCorner
    @State private var panelWidth: Double
    @State private var launchAtLogin: Bool
    @State private var widgetPath: String

    init(preferences: PreferencesManager) {
        self.preferences = preferences
        _selectedCorner = State(initialValue: preferences.hotCorner)
        _panelWidth = State(initialValue: Double(preferences.panelWidth))
        _launchAtLogin = State(initialValue: preferences.launchAtLogin)
        _widgetPath = State(initialValue: preferences.widgetFilePath)
    }

    var body: some View {
        Form {
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

            Section("Keyboard Shortcut") {
                HStack {
                    Text("Toggle Panel")
                    Spacer()
                    Text("Cmd + Shift + W")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary)
                        .cornerRadius(6)
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
        .frame(width: 420, height: 400)
    }
}
