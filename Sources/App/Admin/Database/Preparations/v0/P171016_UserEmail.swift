import Foundation
import FluentProvider

class P171016_UserEmail: Preparation {
    
    static func prepare(_ database: Database) throws {
        print("P171016_UserEmail")
        try database.transaction { conn in
            try database.modify(User.self) { builder in
                builder.string("email", optional: false)
                builder.date("last_login", optional: true)
                builder.bool("has_image", default: false)
            }
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.transaction { conn in
            try database.modify(User.self) { builder in
                builder.delete("email")
                builder.delete("last_login")
                builder.delete("has_image")
            }
        }
    }
    
}

