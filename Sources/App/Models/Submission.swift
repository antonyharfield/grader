import Foundation
import FluentProvider

final class Submission: Model, NodeRepresentable, Timestampable {
    
    var eventProblemID: Identifier
    var userID: Identifier
    var files: [String]
    var state: SubmissionState
    var score: Int
    var compilerOutput: String
    
    var eventProblem: Parent<Submission, EventProblem> {
        return parent(id: eventProblemID)
    }
    
    var user: Parent<Submission, User> {
        return parent(id: userID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        eventProblemID = try row.get("event_problem_id")
        userID = try row.get("user_id")
        files = (try row.get("files") as String).components(separatedBy: "\n")
        state = try row.get("state")
        score = try row.get("score")
        compilerOutput = try row.get("compiler_output")
    }
    
    init(eventProblemID: Identifier, userID: Identifier, files: [String], state: SubmissionState = .submitted, score: Int = 0, compilerOutput: String = "") {
        self.eventProblemID = eventProblemID
        self.userID = userID
        self.files = files
        self.state = state
        self.score = score
        self.compilerOutput = compilerOutput
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("event_problem_id", eventProblemID)
        try row.set("user_id", userID)
        try row.set("files", files.joined(separator: "\n"))
        try row.set("state", state.rawValue)
        try row.set("score", score)
        try row.set("compiler_output", compilerOutput)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "eventProblemID": eventProblemID,
            "userID": userID,
            "files": files,
            "state": state,
            "score": score,
            "compilerOutput": compilerOutput])
    }
}

extension Submission: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(EventProblem.self, optional: false)
            builder.parent(User.self, optional: false)
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
