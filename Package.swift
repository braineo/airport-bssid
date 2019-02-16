// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "bssid",
    dependencies: [
        .package(url: "https://github.com/nsomar/Guaka.git", from: "0.0.0"),
    ],
    targets: [
        .target(
            name: "bssid",
            dependencies: ["Guaka"]),
    ]
)
