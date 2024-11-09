//
//  JWTAuthMiddleware.swift
//  Tag-It-Server
//
//  Created by Aurélien on 09/11/2024.
//

import Vapor
import JWT

struct JWTAuthMiddleware: Middleware {
    private let publicPaths: [(method: HTTPMethod, path: String)]

    init(publicPaths: [(method: HTTPMethod, path: String)]) {
        self.publicPaths = publicPaths
    }

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
