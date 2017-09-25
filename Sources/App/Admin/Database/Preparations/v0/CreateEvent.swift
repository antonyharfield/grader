import Foundation
import FluentProvider

extension Event: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(User.self, optional: false)
            builder.string("name")
            builder.date("starts_at", optional: true)
            builder.date("ends_at", optional: true)
            builder.string("language_restriction", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
