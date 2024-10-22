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
        favorites.post(use: create)
    }
    
    @Sendable
    func index(req: Request) async throws -> [Favorite] {
            return try await Favorite.query(on: req.db).all()
    }
    
    @Sendable
    func create(req: Request) async throws -> Favorite {
        let favorite = try req.content.decode(Favorite.self)
        try await favorite.save(on: req.db)
        return favorite
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let favorite = try await
                Favorite.find(req.parameters.get("favoriteID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await favorite.delete(on: req.db)
        return .noContent
    }
}
