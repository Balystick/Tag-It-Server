import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {

app.http.server.configuration.port = 8080

// Décommenter pour un accès externe
//app.http.server.configuration.hostname = "0.0.0.0"

app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "tag_it"
    ), as: .mysql)

    // register routes
    try routes(app)
    
}
