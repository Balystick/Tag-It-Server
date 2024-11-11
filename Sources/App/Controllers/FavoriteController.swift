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
    /// Cette méthode traite les requêtes `GET /favorites` et renvoie une liste de tous les favoris de l'utilisateur connecté.
    /// - Parameter req: La requête entrante contenant les informations d'authentification de l'utilisateur.
    /// - Returns: Une liste d'objets `FavoriteDTO` représentant les favoris de l'utilisateur.
    /// - Throws: Une erreur si la récupération des favoris échoue ou si l'utilisateur n'est pas authentifié.
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
    /// Cette méthode traite les requêtes `POST /favorites`, en décodant un objet `FavoriteDTO` et en l'associant à l'utilisateur connecté avant de l'enregistrer dans la base de données.
    /// - Parameter req: La requête entrante contenant les informations du favori à créer.
    /// - Returns: L'objet `FavoriteDTO` représentant le favori créé, incluant son identifiant.
    /// - Throws: Une erreur si la création du favori échoue ou si l'utilisateur n'est pas authentifié.
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
    /// Cette méthode traite les requêtes `DELETE /favorites/:favoriteID`, en recherchant le favori par son identifiant pour le supprimer s'il appartient à l'utilisateur connecté.
    /// - Parameter req: La requête entrante contenant l'identifiant du favori dans les paramètres.
    /// - Returns: Un statut HTTP `.noContent` si la suppression est réussie.
    /// - Throws: Une erreur `badRequest` si l'identifiant est invalide, `notFound` si le favori n'existe pas ou n'appartient pas à l'utilisateur.
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
