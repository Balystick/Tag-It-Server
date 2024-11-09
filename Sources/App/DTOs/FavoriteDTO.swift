//
//  FavoritesDTO.swift
//  Tag-It-Server
//
//  Created by Aurélien on 09/11/2024.
//
import Vapor

struct FavoriteDTO: Content {
    var id: UUID?
    var date_added: String?
    var id_artwork: UUID?
}
