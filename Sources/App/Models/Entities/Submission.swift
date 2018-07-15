import Vapor
import FluentMySQL

final class Submission: Content {
    
    var id: Int?
    var eventProblemID: Int
    var userID: Int
    var language: Language
    var files: String
    var state: SubmissionState
    var score: Int
    var compilerOutput: String
    var createdAt: Date?
    var updatedAt: Date?
    
    var eventProblem: Parent<Submission, EventProblem> {
        return parent(\.eventProblemID)
    }
    
    var user: Parent<Submission, User> {
        return parent(\.userID)
    }
    
    init(id: Int? = nil, eventProblemID: Int, userID: Int, language: Language, files: String, state: SubmissionState = .submitted, score: Int = 0, compilerOutput: String = "") {
        self.id = id
        self.eventProblemID = eventProblemID
        self.userID = userID
        self.language = language
        self.files = files
        self.state = state
        self.score = score
        self.compilerOutput = compilerOutput
    }
}

extension Submission: MySQLModel {
    static let entity = "submissions"
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}
