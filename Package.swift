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
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
  ],
  targets: [
    .target(
      name: "Inject",
      dependencies: [
        "InjectMacros",
      ]
    ),
    .macro(
      name: "InjectMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
  ]
)
