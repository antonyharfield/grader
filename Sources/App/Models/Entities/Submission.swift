import Vapor
import FluentMySQL

final class Submission: Content {
    
    var id: Int?
    var problemID: Int
    var eventProblemID: Int?
    var topicItemID: Int?
    var userID: Int
    var language: Language
    var files: String
    var state: SubmissionState
    var score: Int
    var compilerOutput: String
    var createdAt: Date?
    var updatedAt: Date?
    
    var problem: Parent<Submission, Problem> {
        return parent(\.problemID)
    }
    
    var user: Parent<Submission, User> {
        return parent(\.userID)
    }
    
    init(id: Int? = nil, problemID: Int, eventProblemID: Int? = nil, topicItemID: Int? = nil, userID: Int, language: Language, files: String, state: SubmissionState = .submitted, score: Int = 0, compilerOutput: String = "") {
        self.id = id
        self.problemID = problemID
        self.eventProblemID = eventProblemID
        self.topicItemID = topicItemID
        self.userID = userID
        self.language = language
        self.files = files
        self.state = state
        self.score = score
        self.compilerOutput = compilerOutput
    }
    
    var filesArray: [String] {
        return files.components(separatedBy: ",")
    }
}

extension Submission: MySQLModel {
    static let entity = "submissions"
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}
