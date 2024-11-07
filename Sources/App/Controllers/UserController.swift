//
//  UserController.swift
//  Tag-It-Server
//
//  Created by Aurélien on 23/10/2024.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        let basicAuthMiddleware = User.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let authGroup = users.grouped(basicAuthMiddleware, guardAuthMiddleware)
        
        let tokenAuthMiddleware = TokenSession.authenticator()
        let guardTokenMiddleware = TokenSession.guardMiddleware()
        let token = users.grouped(tokenAuthMiddleware, guardTokenMiddleware)

        users.post(use: self.createUser)
        authGroup.post("login", use: self.login)
        
        users.get(":userId", use: getUserById) // Test
//        token.get(":userId", use: getUserById)
        token.put(":userId", use: updateUserById)
        token.get("me", use: getUserFromToken)
    }
}

extension UserController {
    @Sendable
    func createUser(req: Request) async throws -> [String:String] {
        let create = try req.content.decode(User.self)

        guard try await User.query(on: req.db).filter(\.$email == create.email).first() == nil else {
            throw Abort(.conflict, reason: "An account with this email already exists.")
        }

        guard create.password.count > 8 else {
            throw Abort(.badRequest, reason: "Your password must to be more than 8 characters.")
        }

        let user = User(
            username: create.username,
            name: create.name,
            image: create.image,
            email: create.email.lowercased(),
            password: try Bcrypt.hash(create.password),
            points: create.points
        )
        try await user.save(on: req.db)
        
        let payload = try TokenSession(with: user)
        let token = try await req.jwt.sign(payload)

        return ["token": token]
    }
    
    @Sendable
    func login(req: Request) async throws -> [String:String] {
        let user = try req.auth.require(User.self)
        let payload = try TokenSession(with: user)
        let token = try await req.jwt.sign(payload)

        return ["token": token]
    }
    
    @Sendable
    func getUserById(req: Request) async throws -> UserDTO {
        guard let user = try await User.find(req.parameters.get("userId", as: UUID.self), on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return user.toDTO()
    }
    
    @Sendable
    func updateUserById(req: Request) async throws -> UserDTO {
        guard let userIDString = req.parameters.get("userId"),
              let userId = UUID(uuidString: userIDString) else {
            throw Abort(. badRequest, reason: "ID d'utilisateur invalide.")
        }
        
        let updatedUser = try req.content.decode(User.self)
        
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "Utilisateur non trouvé.")
        }
        
        user.username = updatedUser.username
        user.name = updatedUser.name
        user.email = updatedUser.email
        user.password = updatedUser.password
        user.points = updatedUser.points
        
        try await user.save(on: req.db)
        return user.toDTO()
    }
    
    @Sendable
    func getUserFromToken(req: Request) throws -> EventLoopFuture<UserDTO> {
        let user = try req.auth.require(User.self)
        return req.eventLoop.makeSucceededFuture(user.toDTO())
    }
}
