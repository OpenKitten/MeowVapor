// swift-tools-version:4.2
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
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "5.1.1"),
        .package(url: "https://github.com/OpenKitten/Meow.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/core.git", from: "3.5.0"),
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
