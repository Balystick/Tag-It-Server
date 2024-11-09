//
//  CreateUserRequest.swift
//  Tag-It-Server
//
//  Created by Aurélien on 09/11/2024.
//

import Vapor

struct CreateUserRequest: Content {
    var username: String
    var email: String
    var password: String
}
