//
//  ArtworkController.swift
//  Tag-It-Server
//
//  Created by Aurélien on 17/10/2024.
//

import Vapor
import Fluent

struct ArtworkController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let artworks = routes.grouped("artworks")
            artworks.get(use: index)
            artworks.post(use: create)
            
            artworks.group(":artworkID") { artwork in
                artwork.get(use: self.getArtworkByID)
            }
            
            @Sendable
            func index(req: Request) async throws -> [Artwork] {
                return try await Artwork.query(on: req.db).all()
            }
            
            @Sendable
            func create(req: Request) async throws -> Artwork {
                let artworks = try req.content.decode(Artwork.self)
                try await artworks.save(on: req.db)
                return artworks
        }
    }
}

extension ArtworkController {
    @Sendable
    func getArtworkByID(req: Request) async throws -> Artwork {
        guard let artwork = try await Artwork.find(req.parameters.get("artworkID"), on: req.db) else {
            throw Abort(.notFound, reason: "Artwork doesn't exist.")
        }
        return artwork
    }
}
