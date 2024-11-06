//
//  Artwork.swift
//  Tag-It-Server
//
//  Created by Aurélien on 17/10/2024.
//
import Vapor
import Fluent
import struct Foundation.UUID

final class Artwork: Model, Content, @unchecked Sendable {
    static let schema = "artworks"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String?
    
    @Field(key: "image")
    var image: String?
    
    @Field(key: "type")
    var type: String?
    
    @Field(key: "address")
    var address: String?
    
    @Field(key: "city")
    var city: String?
    
    @Field(key: "country")
    var country: String?
    
    @Field(key: "date")
    var date: String?
    
    @Field(key: "latitude")
    var latitude: Double?
    
    @Field(key: "longitude")
    var longitude: Double?
    
    @Field(key: "points")
    var points: String?
    
    @Field(key: "id_artist")
    var id_artist: UUID?
    
    @Field(key: "artist_name")
    var artist_name: String?

    init() { }
}
