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
    @Sendable
    func getArtworks(req: Request) async throws -> [Artwork] {
        if let sql = req.db as? SQLDatabase {
            let artworks = try await sql.raw("SELECT artworks.*, artists.name AS artist_name FROM artworks JOIN artists ON id_artist = artists.id").all(decodingFluent: Artwork.self)
            return artworks
        }
        throw Abort(.internalServerError, reason: "It's not a SQL database.")
    }
    
    @Sendable
    func createArtwork(req: Request) async throws -> Artwork {
        let artwork = try req.content.decode(Artwork.self)
        try await artwork.save(on: req.db)
        return artwork
    }
    
    @Sendable
    func getArtworkByID(req: Request) async throws -> Artwork {
        guard let artwork = try await Artwork.find(req.parameters.get("artworkID"), on: req.db) else {
            throw Abort(.notFound, reason: "Artwork doesn't exist.")
        }
        return artwork
    }
    
    @Sendable
    func deleteArtworkByID(req: Request) async throws -> HTTPStatus {
        guard let artwork = try await Artwork.find(req.parameters.get("artworkID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await artwork.delete(on: req.db)
        
        return .noContent
    }
}
