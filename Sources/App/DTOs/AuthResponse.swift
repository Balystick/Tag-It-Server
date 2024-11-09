//
//  UserRegistrationResponse.swift
//  Tag-It-Server
//
//  Created by Aurélien on 09/11/2024.
//
import Vapor

struct AuthResponse: Content {
    let user: UserDTO
    let token: String
}
