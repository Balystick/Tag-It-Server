import NIOSSL
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    
    app.http.server.configuration.port = 8080
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "tag_it"
    ), as: .mysql)
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin : .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 8
    )
    
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    
    app.middleware.use(corsMiddleware)
    try routes(app)
}
