//
//  Favorite.swift
//  Tag-It-Server
//
//  Created by Aurélien on 22/10/2024.
//

import Vapor
import Fluent
import struct Foundation.UUID

final class Favorite: Model, Content, @unchecked Sendable  {
    static let schema = "favorites"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "date_added")
    var date_added: String?
    
    @Field(key: "id_artwork")
    var id_artwork: UUID?

    @Field(key: "id_user")
    var id_user: UUID?
}
