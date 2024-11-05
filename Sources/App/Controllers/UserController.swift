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
        users.post(use: self.createUser)
        
//        users.get(":userId", use: getUserById)
//        users.put(":userId", use: updateUserById)
    }
}

extension UserController {
    @Sendable
    func createUser(req: Request) async throws -> UserDTO {
        let create = try req.content.decode(User.self)
        
        print(create)

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

        return user.toDTO()
    }
    
    @Sendable
    func getUserById(req: Request) async throws -> User {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid UUID format")
        }
        
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return user
    }
    
    @Sendable
    func updateUserById(req: Request) async throws -> User {
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
        return user
    }
}
