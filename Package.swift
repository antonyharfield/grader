// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Grader",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/multipart.git", from: "3.0.0"),
        .package(url: "https://github.com/nodes-vapor/flash.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor-community/jobs-redis-driver.git", from: "0.2.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Command", "FluentMySQL", "Leaf", "Authentication", "Multipart", "Flash", "JobsRedisDriver"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

