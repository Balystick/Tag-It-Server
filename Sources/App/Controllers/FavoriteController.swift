//
//  FavoriteController.swift
//  Tag-It-Server
//
//  Created by Aurélien on 22/10/2024.
//

import Vapor
import Fluent

struct FavoriteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let favorites = routes.grouped("favorites")
        favorites.get(use: getFavoritesByUser)
        favorites.post(use: create)
        favorites.delete(":favoriteID", use: delete)
    }
}

extension FavoriteController {
    @Sendable
    func getFavoritesByUser(req: Request) async throws -> [Favorite] {
        guard let userID = req.query[UUID.self, at: "id_user"] else {
            throw Abort(.badRequest, reason: "id_user manquant")
        }
        return try await Favorite.query(on: req.db)
            .filter(\.$id_user == userID)
            .all()
    }
    
    @Sendable
    func create(req: Request) async throws -> Favorite {
        let favorite = try req.content.decode(Favorite.self)
        try await favorite.save(on: req.db)
        return favorite
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let favoriteID = req.parameters.get("favoriteID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID du favori invalide")
        }
        
        guard let favorite = try await Favorite.find(favoriteID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await favorite.delete(on: req.db)
        return .noContent
    }
}
