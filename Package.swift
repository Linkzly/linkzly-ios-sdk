// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "LinkzlySDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Linkzly",
            targets: ["Linkzly"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "Linkzly",
            path: "Sources/Linkzly.xcframework"
        ),
    ]
)
