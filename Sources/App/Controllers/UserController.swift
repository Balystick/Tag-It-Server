//
//  UserController.swift
//  Tag-It-Server
//
//  Created by Aurélien on 23/10/2024.
//
import Fluent
import Vapor
import JWT

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoutes = routes.grouped("users")
        
        usersRoutes.post("create", use: createUser)
        usersRoutes.post("login", use: login)
    }
    /// Cette méthode traite les requêtes `POST /users/create`. Elle vérifie si un compte avec  l'email existe déjà, et si non, crée un nouvel utilisateur, génère un token JWT, et retourne les informations de l'utilisateur avec le token.
    /// - Parameter req: La requête entrante contenant les informations d'inscription de l'utilisateur.
    /// - Returns: Un objet `AuthResponse` contenant les informations de l'utilisateur et le token JWT.
    /// - Throws: Une erreur `badRequest` si l'email existe déjà, ou une erreur lors de l'enregistrement ou du hachage du mot de passe.
    @Sendable
    func createUser(req: Request) async throws -> AuthResponse {
        // Décoder la requête d'inscription
        let createUserRequest = try req.content.decode(CreateUserRequest.self)

        // Vérifier si l'utilisateur existe déjà
        let existingUser = try await User.query(on: req.db)
            .filter(\.$email == createUserRequest.email)
            .first()

        guard existingUser == nil else {
            throw Abort(.badRequest, reason: "An account with this email already exists.")
        }

        let passwordHash = try Bcrypt.hash(createUserRequest.password)
        
        let user = User(
            username: createUserRequest.username,
            email: createUserRequest.email,
            passwordHash: passwordHash
        )
        
        try await user.save(on: req.db)

        let token = try await req.generateToken(for: user)
        
        let userDTO = user.toDTO()
        
        return AuthResponse(user: userDTO, token: token)
    }
    /// Cette méthode traite les requêtes `POST /users/login`, en vérifiant l'email et le mot de passe fournis. Si les informations sont correctes, elle génère un token JWT et retourne les informations de l'utilisateur avec le token.
    /// - Parameter req: La requête entrante contenant les informations de connexion de l'utilisateur.
    /// - Returns: Un objet `AuthResponse` contenant les informations de l'utilisateur et le token JWT.
    /// - Throws: Une erreur `unauthorized` si l'email ou le mot de passe est invalide.
    @Sendable
    func login(req: Request) async throws -> AuthResponse {
        let loginRequest = try req.content.decode(LoginRequest.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid email or password.")
        }

        guard try Bcrypt.verify(loginRequest.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid email or password.")
        }

        let token = try await req.generateToken(for: user)

        let userDTO = user.toDTO()

        return AuthResponse(user: userDTO, token: token)
    }
}

extension Request {
    /// Cette méthode crée un `Payload` contenant l'identifiant de l'utilisateur et une date d'expiration. Elle signe ensuite ce payload pour générer un token JWT.
    /// - Parameter user: L'utilisateur pour lequel le token est généré.
    /// - Returns: Une chaîne de caractères représentant le token JWT.
    /// - Throws: Une erreur si l'identifiant de l'utilisateur est invalide ou si la génération du token échoue.
    func generateToken(for user: User) async throws -> String {
        let payload = Payload(
//            expiration: .init(value: .distantFuture),
            expiration: .init(value: Date().addingTimeInterval(30)),
            userId: try user.requireID()
        )
        return try await self.jwt.sign(payload)
    }
}
