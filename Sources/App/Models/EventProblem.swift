import Foundation
import FluentProvider

final class EventProblem: Model, NodeRepresentable {
    
    var eventID: Identifier
    var problemID: Identifier
    
    let storage = Storage()
    
    init(row: Row) throws {
        eventID = try row.get("event_id")
        problemID = try row.get("problem_id")
    }
    
    init(eventID: Identifier, problemID: Identifier) {
        self.eventID = eventID
        self.problemID = problemID
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("event_id", eventID)
        try row.set("problem_id", problemID)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id!.string!,
            "eventID": eventID,
            "problemID": problemID])
    }
}

extension EventProblem: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Event.self, optional: false)
            builder.parent(Problem.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
