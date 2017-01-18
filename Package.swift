import PackageDescription

let package = Package(
    name: "MeowVapor",
    targets: [
        Target(name: "MeowVaporTemplating"),
        Target(name: "BSONTemplating"),
        Target(name: "MeowVapor", dependencies: ["MeowVaporTemplating", "BSONTemplating"]),
        Target(name: "MeowSample", dependencies: ["MeowVapor"])
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 3),
        .Package(url: "https://github.com/Vapor/Vapor.git", majorVersion: 1)
    ]
)
