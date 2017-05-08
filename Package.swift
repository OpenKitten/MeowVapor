import PackageDescription

let package = Package(
    name: "MeowVapor",
    targets: [
        Target(name: "MeowVapor"),
        Target(name: "MeowSample", dependencies: ["MeowVapor"])
    ],
    dependencies: [
    ]
)
