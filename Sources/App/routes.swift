import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "I GET hello!"
    }
    
    app.post("hello") { req async -> String in
        "I POST hello!"
    }
    
    app.put("hello") { req async -> String in
        "I PUT hello!"
    }
    
    app.delete("hello") { req async -> String in
        "I DELETE hello!"
    }

    try app.register(collection: ArtworkController())
}
