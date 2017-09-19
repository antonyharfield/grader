import Foundation
import FluentProvider

extension EventProblem: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Event.self, optional: false)
            builder.parent(Problem.self, optional: false)
            builder.int("sequence")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
