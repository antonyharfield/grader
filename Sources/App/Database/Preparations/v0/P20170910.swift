import Foundation
import FluentProvider

final class P20170910: Preparation {
    
    static func prepare(_ database: Database) throws {
        try User.prepare(database)
        try Problem.prepare(database)
        try ProblemCase.prepare(database)
        try Event.prepare(database)
        try EventProblem.prepare(database)
        try Submission.prepare(database)
        try ResultCase.prepare(database)
    }
    
    static func revert(_ database: Database) throws {
        try ResultCase.revert(database)
        try Submission.revert(database)
        try EventProblem.revert(database)
        try Event.revert(database)
        try ProblemCase.revert(database)
        try Problem.revert(database)
        try User.revert(database)
    }
    
}

extension Event: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.parent(User.self, optional: false)
            builder.date("starts_at", optional: true)
            builder.date("ends_at", optional: true)
            builder.string("language_restriction", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}

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


extension Submission: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(EventProblem.self, optional: false)
            builder.parent(User.self, optional: false)
            builder.string("language")
            builder.string("files")
            builder.int("state")
            builder.int("score")
            builder.string("compiler_output")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}

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
