// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "BaseKit",
  platforms: [.iOS(.v11)],
  products: [
    .library(
      name: "BaseKit",
      targets: ["BaseKit"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "BaseKit",
      dependencies: []),
    .testTarget(
      name: "BaseKitTests",
      dependencies: ["BaseKit"]),
  ]
)
