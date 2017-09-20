import Foundation
import FluentProvider

final class Event: Model, NodeRepresentable {
    
    var name: String
    var userID: Identifier
    var startsAt: Date?
    var endsAt: Date?
    var languageRestriction: Language?
    
    var user: Parent<Event, User> {
        return parent(id: userID)
    }
    var eventProblems: Children<Event, EventProblem> {
        return children()
    }
    var problems: Siblings<Event, Problem, EventProblem> {
        return siblings()
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        userID = try row.get("user_id")
        startsAt = try row.get("starts_at")
        endsAt = try row.get("ends_at")
        if let languageRestriction = try row.get("language_restriction") as String? {
            self.languageRestriction = Language(rawValue: languageRestriction)
        }
    }
    
    init(name: String, userID: Identifier, startsAt: Date? = nil, endsAt: Date? = nil, languageRestriction: Language? = nil) {
        self.name = name
        self.userID = userID
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.languageRestriction = languageRestriction
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("user_id", userID)
        try row.set("starts_at", startsAt)
        try row.set("ends_at", endsAt)
        try row.set("language_restriction", languageRestriction?.rawValue)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id!.makeNode(in: context),
            "name": name.makeNode(in: context),
            "userID": userID.makeNode(in: context),
            "startsAt": startsAt,
            "endsAt": endsAt,
            "languageRestriction": languageRestriction ?? ""])
    }
    
    func isVisible(to user: User) -> Bool {
        // TBD: Replace roles with permissions => grant permission to both teacher and admin roles
        return user.has(role: .teacher) || user.has(role: .admin) || isPubliclyVisible()
    }
    
    func isPubliclyVisible() -> Bool {
        return startsAt == nil || startsAt! < Date()
    }
}
