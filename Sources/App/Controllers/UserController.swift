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
    func generateToken(for user: User) async throws -> String {
        let payload = Payload(
            expiration: .init(value: .distantFuture), // modifier la durée ?
            userId: try user.requireID()
        )
        return try await self.jwt.sign(payload)
    }
}
