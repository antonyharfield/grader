import Foundation
import FluentProvider

final class ResultCase: Model, NodeRepresentable {
    
    var submissionID: Identifier
    var problemCaseID: Identifier
    var output: String
    var pass: Bool
    
    var submission: Parent<ResultCase, Submission> {
        return parent(id: problemCaseID)
    }
    
    var problemCase: Parent<ResultCase, ProblemCase> {
        return parent(id: problemCaseID)
    }

    let storage = Storage()
    
    init(row: Row) throws {
        submissionID = try row.get("submission_id")
        problemCaseID = try row.get("problem_case_id")
        output = try row.get("output")
        pass = try row.get("pass")
    }
    
    init(submissionID: Identifier, problemCaseID: Identifier, output: String, pass: Bool) {
        self.submissionID = submissionID
        self.problemCaseID = problemCaseID
        self.output = output
        self.pass = pass
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("submission_id", submissionID)
        try row.set("problem_case_id", problemCaseID)
        try row.set("output", output)
        try row.set("pass", pass)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "submissionID": submissionID,
            "problemCaseID": problemCaseID,
            "output": output,
            "pass": pass])
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
