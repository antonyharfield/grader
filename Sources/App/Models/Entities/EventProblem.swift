import Vapor
import FluentMySQL

final class EventProblem: Content {
    
    var id: Int?
    var eventID: Int
    var problemID: Int
    var sequence: Int
    
    var event: Parent<EventProblem, Event> {
        return parent(\.eventID)
    }
    
    var problem: Parent<EventProblem, Problem> {
        return parent(\.problemID)
    }
    
    var submissions: Children<EventProblem, Submission> {
        return children(\.eventProblemID)
    }
    
    init(id: Int? = nil, eventID: Int, problemID: Int, sequence: Int) {
        self.id = id
        self.eventID = eventID
        self.problemID = problemID
        self.sequence = sequence
    }
}

extension EventProblem: MySQLModel {
    static let entity = "event_problems"
}

extension EventProblem: Pivot {
    typealias Left = Event
    typealias Right = Problem
    static let leftIDKey: LeftIDKey = \.eventID
    static let rightIDKey: RightIDKey = \.problemID
}
