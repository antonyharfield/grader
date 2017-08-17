import PackageDescription

let package = Package(
    name: "agrader",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"]),
        Target(name: "Worker", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/auth-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/validation.git", majorVersion: 0),
        .Package(url: "https://github.com/nodes-vapor/flash.git", majorVersion: 1),
        .Package(url: "https://github.com/BrettRToomey/Jobs.git", majorVersion: 1),
        .Package(url: "https://github.com/reswifq/reswifq.git", majorVersion: 1),
        .Package(url: "https://github.com/reswifq/redis-client-vapor", majorVersion: 1),
        .Package(url: "https://github.com/vapor/redis.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Public",
        "Resources",
    ]
)

