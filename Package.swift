// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GlanceBar",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "GlanceBar",
            path: "Sources/GlanceBar",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("WebKit"),
                .linkedFramework("ServiceManagement"),
            ]
        )
    ]
)
