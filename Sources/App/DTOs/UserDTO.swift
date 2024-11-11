//
//  UserDTO.swift
//  Tag-It-Server
//
//  Created by Apprenant 124 on 05/11/2024.
//

import Vapor

struct UserDTO: Content {
    var username: String
    var email: String
    var image: String
    var points: Int
}
