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
        users.get(":userId", use: getUserById)
        users.put(":userId", use: updateUserById)
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
            // Mise à jour des propriétés
            user.username = updatedUser.username
            user.name = updatedUser.name
            user.email = updatedUser.email
            user.password = updatedUser.password
            user.points = updatedUser.points
            try await user.save(on: req.db)
            return user
    }
}
