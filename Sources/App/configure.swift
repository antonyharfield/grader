import Authentication
import Flash
import FluentMySQL
import Jobs
import JobsRedisDriver
import Leaf
import Redis
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    try services.register(FlashProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    middlewares.use(FlashMiddleware.self)
    services.register(middlewares)
    
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self) // For sessions

    /// Configure CLI commands
    services.register { container -> CommandConfig in
        var commandConfig = CommandConfig.default()
        commands(&commandConfig)
        return commandConfig
    }

    var databases = DatabasesConfig()

    /// Configure the mysql database
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: "192.168.99.100", // "database",
        port: 3306,
        username: "root",
        password: "test1234",
        database: "grader"
    )
    databases.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
    databases.enableLogging(on: .mysql)
    
    /// Redis
    try services.register(RedisProvider())
    let redisUrlString = "redis://192.168.99.100:6379"
    guard let redisUrl = URL(string: redisUrlString) else { throw Abort(.internalServerError) }
    let redisConfig = try RedisDatabase(config: RedisClientConfig(url: redisUrl))
    databases.add(database: redisConfig, as: .redis)

    services.register(databases)
    
    /// Jobs
    services.register(JobsPersistenceLayer.self) { container -> JobsRedisDriver in
        return JobsRedisDriver(database: redisConfig, eventLoop: container.next())
    }
    try jobs(&services)
    
    /// Call the migrations
    services.register { container -> MigrationConfig in
        var migrationConfig = MigrationConfig()
        try migrate(&migrationConfig)
        return migrationConfig
    }

    configureLeaf(&services)
}
