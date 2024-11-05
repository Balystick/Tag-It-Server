//
//  User.swift
//  Tag-It-Server
//
//  Created by Aurélien on 21/10/2024.
//
import Fluent
import Vapor

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "image")
    var image: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "points")
    var points: Int
    
    init() { }
    
    init(id: UUID? = nil, username: String, name: String, image: String, email: String, password: String, points: Int) {
        self.id = id
        self.username = username
        self.name = name
        self.image = image
        self.email = email
        self.password = password
        self.points = points
    }
    
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            username: self.$username.value,
            name: self.$name.value,
            image: self.$image.value,
            email: self.$email.value,
            points: self.$points.value
        )
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
