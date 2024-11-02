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
    .iOS(.v15)
  ],
  products: [
    .library(
      name: "BaseKit",
      targets: [
        "BaseKit"
      ]
    ),
  ],
  targets: [
    .target(
      name: "BaseKit",
      path: "Sources"
    ),
    .testTarget(
      name: "BaseKitTests",
      dependencies: [
        "BaseKit"
      ],
      path: "Tests"
    ),
  ]
)
