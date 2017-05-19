import PackageDescription

let package = Package(
    name: "MeowVapor",
    targets: [
        Target(name: "MeowVapor")
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/Meow.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2)
    ]
)
