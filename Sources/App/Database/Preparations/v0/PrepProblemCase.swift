import Foundation
import FluentProvider

extension ProblemCase: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("input")
            builder.string("output")
            builder.bool("visible")
            builder.parent(Problem.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
