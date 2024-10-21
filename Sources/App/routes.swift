import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

//    app.post("upload-image") { req -> EventLoopFuture<Response> in
//        let data = try req.content.decode(User.self) // Assuming the User model has a name and image
//        
//        guard let imageData = req.body.data else {
//            throw Abort(.badRequest, reason: "No image data received.")
//        }
//
//        // Save the image to the file system or cloud storage
//        let fileName = UUID().uuidString + ".jpg"
//        let filePath = "/Public/user/\(fileName)"
//
//        // Save the file (this example assumes you have permission to write to this path)
////        try imageData.write(to: URL(fileURLWithPath: filePath))
//
//        // Save user data
//        data.profileImage = fileName // Save the file name in the database
//        return data.save(on: req.db).map {
//            return req.response
//        }
//    }
    try app.register(collection: ArtworkController())
}
