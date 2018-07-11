import Authentication
import Flash
import FluentMySQL
import Leaf
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
    
    /// Configure the database
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: "192.168.99.100", // "database",
        port: 3306,
        username: "root",
        password: "test1234",
        database: "grader"
    )
    services.register(mysqlConfig)

    /// Call the migrations
    services.register { container -> MigrationConfig in
        var migrationConfig = MigrationConfig()
        try migrate(&migrationConfig)
        return migrationConfig
    }
    
    configureLeaf(&services)
}
