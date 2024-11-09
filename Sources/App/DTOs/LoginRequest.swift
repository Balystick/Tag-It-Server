//
//  LoginRequest.swift
//  Tag-It-Server
//
//  Created by Aurélien on 09/11/2024.
//

import Vapor

struct LoginRequest: Content {
    let email: String
    let password: String
}

