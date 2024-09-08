// swift-tools-version:5.8

import PackageDescription

let package = Package(
  name: "Injection",
  platforms: [.macOS(.v12), .iOS(.v16)],
  products: [
    .library(name: "Injection", targets: ["Injection"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Injection",
      dependencies: []
    ),
  ]
)
