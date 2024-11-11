//
//  ArtworkController.swift
//  Tag-It-Server
//
//  Created by Aurélien on 17/10/2024.
//

import Vapor
import Fluent
import FluentSQL

struct ArtworkController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let artworks = routes.grouped("artworks")
        artworks.get(use: getArtworks)
        artworks.post(use: createArtwork)
        
        artworks.group(":artworkID") { artwork in
            artwork.get(use: self.getArtworkByID)
            artwork.delete(use: self.deleteArtworkByID)
        }
    }
}

extension ArtworkController {
    /// Cette méthode exécute une requête SQL brute pour obtenir les artworks en les triant par date descendante. Elle récupère également le nom de l’artiste associé pour chaque artwork.
    /// - Parameter req: La requête entrante.
    /// - Returns: Une liste d’objets `Artwork` décodés, chacun avec les données de l’artiste associé.
    /// - Throws: Une erreur si la base de données n’est pas compatible SQL.
    @Sendable
    func getArtworks(req: Request) async throws -> [Artwork] {
        if let sql = req.db as? SQLDatabase {
            let artworks = try await sql.raw("SELECT artworks.*, artists.name AS artist_name FROM artworks JOIN artists ON id_artist = artists.id ORDER BY date DESC").all(decodingFluent: Artwork.self)
            return artworks
        }
        throw Abort(.internalServerError, reason: "It's not a SQL database.")
    }
    /// Cette méthode décode un objet `Artwork` à partir des données de la requête et l'enregistre dans la base de données.
    /// - Parameter req: La requête entrante contenant les données de l’artwork.
    /// - Returns: L’objet `Artwork` nouvellement créé.
    /// - Throws: Une erreur si les données de l’artwork sont invalides ou si l’enregistrement échoue.
    @Sendable
    func createArtwork(req: Request) async throws -> Artwork {
        let artwork = try req.content.decode(Artwork.self)
        try await artwork.save(on: req.db)
        return artwork
    }
    /// Cette méthode recherche un artwork par son identifiant (`artworkID`) dans la base de données.
    /// - Parameter req: La requête entrante contenant l'identifiant de l’artwork dans les paramètres.
    /// - Returns: L’objet `Artwork` correspondant à l’identifiant fourni.
    /// - Throws: Une erreur `notFound` si l’artwork n'existe pas.
    @Sendable
    func getArtworkByID(req: Request) async throws -> Artwork {
        guard let artwork = try await Artwork.find(req.parameters.get("artworkID"), on: req.db) else {
            throw Abort(.notFound, reason: "Artwork doesn't exist.")
        }
        return artwork
    }
    /// Cette méthode supprime un artwork de la base de données en utilisant son identifiant (`artworkID`).
    /// - Parameter req: La requête entrante contenant l'identifiant de l’artwork dans les paramètres.
    /// - Returns: Un statut HTTP `.noContent` si la suppression est réussie.
    /// - Throws: Une erreur `notFound` si l’artwork n'existe pas.
    @Sendable
    func deleteArtworkByID(req: Request) async throws -> HTTPStatus {
        guard let artwork = try await Artwork.find(req.parameters.get("artworkID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await artwork.delete(on: req.db)
        return .noContent
    }
}
