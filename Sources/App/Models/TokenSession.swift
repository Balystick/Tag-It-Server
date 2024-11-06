//
//  TokenSession.swift
//  Tag-It-Server
//
//  Created by Apprenant 124 on 05/11/2024.
//

import Vapor
import JWTKit

struct TokenSession: Content, Authenticatable, JWTPayload {
    var expirationTime: TimeInterval = 60 * 1
    var expiration: ExpirationClaim
    var userId: UUID

    init(with user: User) throws {
        self.userId = try user.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
}
