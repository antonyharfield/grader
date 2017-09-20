import Foundation
import FluentProvider

final class EventProblem: Model, NodeRepresentable {
    
    var eventID: Identifier
    var problemID: Identifier
    var sequence: Int
    
    var event: Parent<EventProblem, Event> {
        return parent(id: eventID)
    }
    
    var problem: Parent<EventProblem, Problem> {
        return parent(id: problemID)
    }
    
    var submissions: Children<EventProblem, Submission> {
        return children()
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        eventID = try row.get("event_id")
        problemID = try row.get("problem_id")
        sequence = try row.get("sequence")
    }
    
    init(eventID: Identifier, problemID: Identifier, sequence: Int) {
        self.eventID = eventID
        self.problemID = problemID
        self.sequence = sequence
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("event_id", eventID)
        try row.set("problem_id", problemID)
        try row.set("sequence", sequence)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        let problem = try self.problem.get()
        return try Node(node: [
            "id": id!.string!,
            "eventID": eventID,
            "problemID": problemID,
            "sequence": sequence,
            "problem": problem.makeNode(in: context)])
    }
}
