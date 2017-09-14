import Foundation
import FluentProvider

final class Submission: Model, NodeRepresentable, Timestampable {
    
    var eventProblemID: Identifier
    var userID: Identifier
    var language: Language
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
        language = Language(rawValue: try row.get("language") as String)!
        files = (try row.get("files") as String).components(separatedBy: "\n")
        state = SubmissionState(rawValue: try row.get("state"))!
        score = try row.get("score")
        compilerOutput = try row.get("compiler_output")
    }
    
    init(eventProblemID: Identifier, userID: Identifier, language: Language, files: [String], state: SubmissionState = .submitted, score: Int = 0, compilerOutput: String = "") {
        self.eventProblemID = eventProblemID
        self.userID = userID
        self.language = language
        self.files = files
        self.state = state
        self.score = score
        self.compilerOutput = compilerOutput
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("event_problem_id", eventProblemID)
        try row.set("user_id", userID)
        try row.set("language", language.rawValue)
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
            "language": language,
            "files": files,
            "state": state,
            "score": score,
            "compilerOutput": compilerOutput,
            "createdAt": createdAt?.dateTimeUserString ?? ""])
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
