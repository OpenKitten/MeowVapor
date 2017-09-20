// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "MeowVapor",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MeowVapor",
            targets: ["MeowVapor"]),
        ],
    dependencies: [
        .package(url: "https://github.com/OpenKitten/Meow.git", .revision("51a8638addc71275876572925e1a94dc8d1a031c")),
        .package(url: "https://github.com/vapor/vapor.git", from: "2.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MeowVapor",
            dependencies: ["Meow", "Vapor"]),
        .testTarget(
            name: "MeowVaporTests",
            dependencies: ["MeowVapor"]),
        ]
)
