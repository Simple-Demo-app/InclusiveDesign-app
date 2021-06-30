// swift-tools-version:5.3
import PackageDescription

// To launch a debug version of the app, `open Project.xcworkspace`
let package = Package(
    name: "App",
    platforms: [
        // minimum platform requirement for SwiftUI.App
        .macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "App",
            targets: ["App"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: []),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"]),
    ]
)
