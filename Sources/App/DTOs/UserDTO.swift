//
//  File.swift
//  Tag-It-Server
//
//  Created by Apprenant 124 on 05/11/2024.
//

import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var username: String?
    var name: String?
    var image: String?
    var email: String?
    var points: Int?
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        
        if let username = self.username {
            model.username = username
        }
        if let name = self.name {
            model.name = name
        }
        if let image = self.image {
            model.image = image
        }
        if let email = self.email {
            model.email = email
        }
        if let points = self.points {
            model.points = points
        }
        return model
    }
}
