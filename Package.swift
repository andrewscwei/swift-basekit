// swift-tools-version:5.3

import PackageDescription

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

enum Environment: String {
  case local
  case development
  case production

  static func get() -> Environment {
    if let envPointer = getenv("SWIFT_ENV"), let environment = Environment(rawValue: String(cString: envPointer)) {
      return environment
    }
    else if let envPointer = getenv("CI"), String(cString: envPointer) == "true" {
      return .production
    }
    else {
      return .local
    }
  }
}

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
