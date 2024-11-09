//
//  User.swift
//  Tag-It-Server
//
//  Created by Aurélien on 21/10/2024.
//
import Fluent
import Vapor
import Foundation

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "image")
    var image: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "points")
    var points: Int
    
    init() { }
    
    init(username: String, email: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.image = "userDefault.jpg"
        self.email = email
        self.passwordHash = passwordHash
        self.points = 0
    }
}

extension User {
    func toDTO() -> UserDTO {
        return UserDTO(
            username: self.username,
            email: self.email,
            image: self.image,
            points: self.points
        )
    }
}
