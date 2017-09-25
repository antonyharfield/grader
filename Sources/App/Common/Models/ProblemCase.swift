import Foundation
import FluentProvider

final class ProblemCase: Model, NodeRepresentable {
    
    var problemID: Identifier?
    var input: String
    var output: String
    var visibility: ProblemCaseVisibility
    
    var problem: Parent<ProblemCase, Problem> {
        return parent(id: problemID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        problemID = try row.get("problem_id")
        input = try row.get("input")
        output = try row.get("output")
        visibility = ProblemCaseVisibility(rawValue: try row.get("visibility")) ?? .show
    }
    
    init(input: String, output: String, visibility: ProblemCaseVisibility = .hide, problemID: Identifier? = nil) {
        self.problemID = problemID
        self.input = input
        self.output = output
        self.visibility = visibility
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("problem_id", problemID)
        try row.set("input", input)
        try row.set("output", output)
        try row.set("visibility", visibility.rawValue)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "problemID": problemID?.string ?? "",
            "input": input,
            "output": output,
            "visibility": visibility.rawValue,
        ])
    }
}
