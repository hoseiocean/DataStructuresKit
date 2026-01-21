// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "DataStructuresKit",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8)
  ],
  products: [
    .library(
      name: "DataStructuresKit",
      targets: ["DataStructuresKit"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3"),
  ],
  targets: [
    .target(
      name: "DataStructuresKit",
      path: "Sources/DataStructuresKit"
    ),
    .testTarget(
      name: "DataStructuresKitTests",
      dependencies: ["DataStructuresKit"],
      path: "Tests/DataStructuresKitTests"
    ),
  ]
)
