//
//  JWTAuthMiddleware.swift
//  Tag-It-Server
//
//  Created by Aurélien on 09/11/2024.
//

import Vapor
import JWT

/// Intercepte les requêtes pour vérifier si elles contiennent un token JWT valide. Si le token est présent et valide, la requête peut continuer. Si le token est manquant ou invalide, une erreur d'autorisation est renvoyée.
struct JWTAuthMiddleware: Middleware {
    private let publicPaths: [(method: HTTPMethod, path: String)]

    init(publicPaths: [(method: HTTPMethod, path: String)]) {
        self.publicPaths = publicPaths
    }
    
    /// Cette fonction traite une requête entrante en vérifiant la présence d'un token JWT valide et en autorisant l'accès public aux chemins définis.
    /// - Parameters:
    ///   - req: L'objet `Request` entrant.
    ///   - next: Le prochain résolveur dans la chaîne de middlewares.
    /// - Returns: Un `EventLoopFuture` de type `Response`, renvoyant un succès si l'utilisateur est authentifié ou échouant avec une erreur d'autorisation.
    func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if publicPaths.contains(where: { $0.method == req.method && $0.path == req.url.path }) {
            return next.respond(to: req)
        }

        return Payload.authenticator().respond(to: req, chainingTo: next).flatMap { response in
            if req.auth.has(Payload.self) {
                return req.eventLoop.makeSucceededFuture(response)
            } else {
                return req.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Authentication required."))
            }
        }
    }
}
