import Vapor
import FluentMySQL

final class ProblemCase: Content {
    
    var id: Int?
    var problemID: Int
    var input: String
    var output: String
    var visibility: ProblemCaseVisibility
    
    var problem: Parent<ProblemCase, Problem> {
        return parent(\.problemID)
    }
    
    init(id: Int? = nil, problemID: Int, input: String, output: String, visibility: ProblemCaseVisibility = .hide) {
        self.id = id
        self.problemID = problemID
        self.input = input
        self.output = output
        self.visibility = visibility
    }
}

extension ProblemCase: MySQLModel {
    static let entity = "problem_cases"
}
