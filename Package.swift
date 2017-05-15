import PackageDescription

let package = Package(
    name: "MeowVapor",
    targets: [
        Target(name: "MeowVapor")
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/Meow.git", Version(0,0,923)),
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"]))
    ]
)
