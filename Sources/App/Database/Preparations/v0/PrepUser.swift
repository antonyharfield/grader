import Foundation
import FluentProvider

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("username")
            builder.string("password")
            builder.int("role")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
