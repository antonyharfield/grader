import Foundation
import FluentProvider

final class ProblemCase: Model, NodeRepresentable {
    
    var problemID: Identifier?
    var input: String
    var output: String
    var visible: Bool
    
    var problem: Parent<ProblemCase, Problem> {
        return parent(id: problemID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        input = try row.get("input")
        output = try row.get("output")
        problemID = try row.get("problem_id")
        visible = try row.get("visible")
    }
    
    init(input: String, output: String, visible: Bool = false, problemID: Identifier? = nil) {
        self.input = input
        self.output = output
        self.visible = visible
        self.problemID = problemID
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("input", input)
        try row.set("output", output)
        try row.set("visible", visible)
        try row.set("problem_id", problemID)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "input": input,
            "output": output,
            "visible": visible,
            "problemID": problemID?.string ?? ""])
    }
}
