import Foundation
import FluentProvider

extension ResultCase: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Submission.self, optional: false)
            builder.parent(ProblemCase.self, optional: false)
            builder.string("output")
            builder.bool("pass")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
