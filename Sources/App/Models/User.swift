//
//  User.swift
//  Tag-It-Server
//
//  Created by Aurélien on 21/10/2024.
//
import Vapor
import Fluent

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "profile_image")
    var profileImage: String?

    init() {}
    
    init(id: UUID? = nil, name: String, profileImage: String? = nil) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
    }
}
