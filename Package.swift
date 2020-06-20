// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "bssid",
    dependencies: [
        .package(url: "https://github.com/nsomar/Guaka.git", from: "0.4.1"),
    ],
    targets: [
        .target(
            name: "bssid",
            dependencies: ["Guaka"]),
    ]
)
