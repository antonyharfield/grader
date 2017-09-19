import Foundation
import FluentProvider

extension Problem: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.text("description")
            builder.string("comparison_method", length: 16)
            builder.bool("comparison_ignores_spaces")
            builder.bool("comparison_ignores_breaks")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
