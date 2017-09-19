import Foundation
import FluentProvider

final class Problem: Model, NodeRepresentable {
    
    var name: String
    var description: String
    var comparisonMethod: ComparisonMethod
    var comparisonIgnoresSpaces: Bool
    var comparisonIgnoresBreaks: Bool
    
    var cases: Children<Problem, ProblemCase> {
        return children()
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        description = try row.get("description")
        comparisonMethod = ComparisonMethod(rawValue: try row.get("comparison_method")) ?? .exactMatch
        comparisonIgnoresSpaces = try row.get("comparison_ignores_spaces")
        comparisonIgnoresBreaks = try row.get("comparison_ignores_breaks")
    }
    
    init(name: String, description: String, comparisonMethod: ComparisonMethod = .exactMatch, comparisonIgnoresSpaces: Bool = false, comparisonIgnoresBreaks: Bool = false) {
        self.name = name
        self.description = description
        self.comparisonMethod = comparisonMethod
        self.comparisonIgnoresSpaces = comparisonIgnoresSpaces
        self.comparisonIgnoresBreaks = comparisonIgnoresBreaks
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("description", description)
        try row.set("comparison_method", comparisonMethod.rawValue)
        try row.set("comparison_ignores_spaces", comparisonIgnoresSpaces)
        try row.set("comparison_ignores_breaks", comparisonIgnoresBreaks)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id?.string ?? "",
            "name": name,
            "description": description,
            "comparisonMethod": comparisonMethod.rawValue,
            "comparisonIgnoresSpaces": comparisonIgnoresSpaces,
            "comparisonIgnoresBreaks": comparisonIgnoresBreaks
        ])
    }
}
