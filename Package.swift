// swift-tools-version:5.8

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
      dependencies: []
    ),
  ]
)
