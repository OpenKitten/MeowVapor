import PackageDescription

let package = Package(
    name: "MeowVapor",
    targets: [
        Target(name: "MeowVapor"),
        Target(name: "MeowSample", dependencies: ["MeowVapor"])
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 3),
        .Package(url: "https://github.com/Vapor/Vapor.git", majorVersion: 1),
        // TODO: .Package(url: "https://github.com/OpenKitten/KittenTemplating.git", majorVersion: 0, minor: 1),
    ]
)
