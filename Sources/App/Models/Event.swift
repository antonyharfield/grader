import Foundation
import FluentProvider

final class Event: Model, NodeRepresentable {
    
    var name: String
    var userID: Identifier
    
    var user: Parent<Event, User> {
        return parent(id: userID)
    }
    var problems: Siblings<Event, Problem, EventProblem> {
        return siblings()
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        userID = try row.get("user_id")
    }
    
    init(name: String, userID: Identifier) {
        self.name = name
        self.userID = userID
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("user_id", userID)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id!.makeNode(in: context),
            "name": name.makeNode(in: context),
            "userID": userID.makeNode(in: context)])
    }
}

extension Event: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.parent(User.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
