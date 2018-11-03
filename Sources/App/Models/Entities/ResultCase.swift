import Vapor
import FluentMySQL

final class ResultCase: Content {
    
    var id: Int?
    var submissionID: Int
    var problemCaseID: Int
    var output: String
    var pass: Bool
    
    var submission: Parent<ResultCase, Submission> {
        return parent(\.problemCaseID)
    }
    
    var problemCase: Parent<ResultCase, ProblemCase> {
        return parent(\.problemCaseID)
    }
    
    init(id: Int? = nil, submissionID: Int, problemCaseID: Int, output: String, pass: Bool) {
        self.id = id
        self.submissionID = submissionID
        self.problemCaseID = problemCaseID
        self.output = String(output.prefix(2000))
        self.pass = pass
    }
}

extension ResultCase: MySQLModel {
    static let entity = "result_cases"
}
