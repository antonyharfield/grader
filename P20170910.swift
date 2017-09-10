import Foundation
import FluentProvider

final class P20170910: Preparation {
    
    static func prepare(_ database: Database) throws {
        try prepareEvent(database)
        try prepareEventProblem(database)
        try prepareProblem(database)
        try prepareProblemCase(database)
        try prepareResultCase(database)
        try prepareSubmission(database)
        try prepareUser(database)
    }
    
    static func revert(_ database: Database) throws {
        try revertEvent(database)
        try revertEventProblem(database)
        try revertProblem(database)
        try revertProblemCase(database)
        try revertResultCase(database)
        try revertSubmission(database)
        try revertUser(database)
    }
    
    static func prepareEvent(_ database: Database) throws {
        try database.create(Event.self) { builder in
            builder.id()
            builder.string("name")
            builder.parent(User.self, optional: false)
            builder.date("starts_at", optional: true)
            builder.date("ends_at", optional: true)
            builder.string("language_restriction", optional: true)
        }
    }
    
    static func revertEvent(_ database: Database) throws {
        try database.delete(Event.self)
    }
    
    static func prepareEventProblem(_ database: Database) throws {
        try database.create(EventProblem.self) { builder in
            builder.id()
            builder.parent(Event.self, optional: false)
            builder.parent(Problem.self, optional: false)
            builder.int("sequence")
        }
    }
    
    static func revertEventProblem(_ database: Database) throws {
        try database.delete(EventProblem.self)
    }
    
    static func prepareProblem(_ database: Database) throws {
        try database.create(Problem.self) { builder in
            builder.id()
            builder.string("name")
            builder.text("description")
            builder.string("comparison_method", length: 16)
            builder.bool("comparison_ignores_spaces")
            builder.bool("comparison_ignores_breaks")
        }
    }
    
    static func revertProblem(_ database: Database) throws {
        try database.delete(Problem.self)
    }
    
    static func prepareProblemCase(_ database: Database) throws {
        try database.create(ProblemCase.self) { builder in
            builder.id()
            builder.string("input")
            builder.string("output")
            builder.bool("visible")
            builder.parent(Problem.self, optional: false)
        }
    }
    
    static func revertProblemCase(_ database: Database) throws {
        try database.delete(ProblemCase.self)
    }
    
    
    static func prepareResultCase(_ database: Database) throws {
        try database.create(ResultCase.self) { builder in
            builder.id()
            builder.parent(Submission.self, optional: false)
            builder.parent(ProblemCase.self, optional: false)
            builder.string("output")
            builder.bool("pass")
        }
    }
    
    static func revertResultCase(_ database: Database) throws {
        try database.delete(ResultCase.self)
    }
    
    static func prepareSubmission(_ database: Database) throws {
        try database.create(Submission.self) { builder in
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
    
    static func revertSubmission(_ database: Database) throws {
        try database.delete(Submission.self)
    }
    
    static func prepareUser(_ database: Database) throws {
        try database.create(User.self) { builder in
            builder.id()
            builder.string("name")
            builder.string("username")
            builder.string("password")
            builder.int("role")
        }
    }
    
    static func revertUser(_ database: Database) throws {
        try database.delete(User.self)
    }
    
}
