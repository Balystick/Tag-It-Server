//
//  Artist.swift
//  Tag-It-Server
//
//  Created by Aurélien on 17/10/2024.
//
import Vapor
import Fluent
import struct Foundation.UUID

final class Artist: Model, Content, @unchecked Sendable {
    static let schema = "artists"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String?

    init() { }
}
