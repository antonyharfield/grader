import Foundation
import FluentProvider

final class ProblemCase: Model, NodeRepresentable {
    
    var problemID: Identifier?
    var input: String
    var output: String
    
    var problem: Parent<ProblemCase, Problem> {
        return parent(id: problemID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        input = try row.get("input")
        output = try row.get("output")
        problemID = try row.get("problem_id")
    }
    
    init(input: String, output: String, problemID: Identifier? = nil) {
        self.input = input
        self.output = output
        self.problemID = problemID
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("input", input)
        try row.set("output", output)
        try row.set("problem_id", problemID)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "input": input,
            "output": output,
            "problemID": problemID?.string ?? ""])
    }
}

extension ProblemCase: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("input")
            builder.string("output")
            builder.parent(Problem.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
