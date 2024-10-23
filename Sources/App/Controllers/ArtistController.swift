//
//  ArtistController.swift
//  Tag-It-Server
//
//  Created by Aurélien on 23/10/2024.
//

import Vapor
import Fluent

struct ArtistController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let artists = routes.grouped("artists")
        artists.get(use: index)
    }
    
    @Sendable
    func index(req: Request) async throws -> [Artist] {
        return try await Artist.query(on: req.db)
            .sort(\.$name, .ascending)
            .all()
    }
}
