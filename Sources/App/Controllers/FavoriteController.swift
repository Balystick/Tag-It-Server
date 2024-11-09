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
        favorites.get(use: getFavorites)
        favorites.post(use: createFavorite)
        favorites.delete(":favoriteID", use: deleteFavorite)
    }
}

extension FavoriteController {
    @Sendable
    func getFavorites(req: Request) async throws -> [FavoriteDTO] {
        let payload = try req.auth.require(Payload.self)
        let userId = payload.userId

        let favorites = try await Favorite.query(on: req.db)
            .filter(\.$id_user == userId)
            .all()

        return favorites.map { favorite in
            FavoriteDTO(
                id: favorite.id,
                date_added: favorite.date_added,
                id_artwork: favorite.id_artwork
            )
        }
    }
    
    @Sendable
    func createFavorite(req: Request) async throws -> FavoriteDTO {
        let payload = try req.auth.require(Payload.self)
        let userId = payload.userId

        let favoriteData = try req.content.decode(FavoriteDTO.self)

        let favorite = Favorite()
        favorite.date_added = favoriteData.date_added
        favorite.id_artwork = favoriteData.id_artwork
        favorite.id_user = userId

        try await favorite.save(on: req.db)

        var responseDTO = favoriteData
        responseDTO.id = favorite.id

        return responseDTO
    }
    
    @Sendable
    func deleteFavorite(req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(Payload.self)
        let userId = payload.userId

        guard let favoriteID = req.parameters.get("favoriteID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID du favori invalide")
        }

        guard let favorite = try await Favorite.query(on: req.db)
            .filter(\.$id == favoriteID)
            .filter(\.$id_user == userId)
            .first() else {
                throw Abort(.notFound, reason: "Favori non trouvé ou n'appartient pas à l'utilisateur")
        }

        try await favorite.delete(on: req.db)
        return .noContent
    }
}
