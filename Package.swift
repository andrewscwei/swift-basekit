// swift-tools-version:5.5

import PackageDescription

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

let package = Package(
  name: "BaseKit",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
    .tvOS(.v15),
    .watchOS(.v8)],
  products: [
    .library(
      name: "BaseKit",
      targets: ["BaseKit"]),
  ],
  targets: [
    .target(
      name: "BaseKit",
      path: "Sources"),
    .testTarget(
      name: "BaseKitTests",
      dependencies: ["BaseKit"],
      path: "Tests"),
  ]
)
