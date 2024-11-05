import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    try app.register(collection: ArtworkController())
    try app.register(collection: FavoriteController())
    try app.register(collection: UserController())
    try app.register(collection: ArtistController())
}
