// swift-tools-version:5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Inject",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [
        .library(name: "Inject", targets: ["Inject"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Inject",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "InjectTests",
            dependencies: [
                "Inject",
            ],
            path: "Tests"
        ),
    ]
)
