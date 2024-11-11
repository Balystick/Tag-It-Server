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
}

extension ArtistController {
    /// Cette méthode traite les requêtes `GET /artists` et renvoie une liste de tous les artistes, triée par nom dans l'ordre croissant.
    /// - Parameter req: La requête entrante.
    /// - Returns: Une liste de tous les objets `Artist` dans la base de données, triés par nom.
    /// - Throws: Une erreur si la récupération des artistes échoue.
    @Sendable
    func index(req: Request) async throws -> [Artist] {
        return try await Artist.query(on: req.db)
            .sort(\.$name, .ascending)
            .all()
    }
}
