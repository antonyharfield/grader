import Foundation
import FluentProvider

final class Problem: Model, NodeRepresentable {
    
    var name: String
    var description: String
    
    var cases: Children<Problem, ProblemCase> {
        return children()
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        description = try row.get("description")
        
    }
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("description", description)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "name": name,
            "description": description])
    }
}

extension Problem: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("description")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
