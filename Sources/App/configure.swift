import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWT
import Gatekeeper

public func configure(_ app: Application) async throws {
    app.http.server.configuration.port = 8080

    // Décommenter pour un accès externe
    //app.http.server.configuration.hostname = "0.0.0.0"

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Database
    app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "root", // à sécuriser par la suite
            password: Environment.get("DATABASE_PASSWORD") ?? "", // à sécuriser par la suite
            database: Environment.get("DATABASE_NAME") ?? "tag_it"
        ), as: .mysql)
    
    // JWT
    guard let secret = Environment.get("SECRET_KEY") else {
        fatalError("JWT secret is not set in environment variables")
    }
    let hmacKey = HMACKey(from: Data(secret.utf8))
    await app.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha256)
    
    
    // CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin : .all, // à restreindre par la suite
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 8
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    
    // Rate Limiter
    app.caches.use(.memory)
    app.gatekeeper.config = .init(maxRequests: 100, per: .minute)
    
    // Middlewares
    app.middleware.use(corsMiddleware)
    app.middleware.use(GatekeeperMiddleware())
    app.middleware.use(JWTAuthMiddleware(publicPaths: [
        (method: .POST, path: "/users/create"),
        (method: .POST, path: "/users/login")
    ]))

    // Register Routes
    try routes(app)
}
