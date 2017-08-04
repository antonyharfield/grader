import Foundation
import FluentProvider

final class Problem: Model, NodeRepresentable {
    
    var name: String
    var language: String
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        language = try row.get("language")
    }
    
    init(name: String, language: String) {
        self.name = name
        self.language = language
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("language", language)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: ["id": id?.string, "name": name, "language": language])
    }
}

extension Problem: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { problems in
            problems.id()
            problems.string("name")
            problems.string("language")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
