import Foundation
import FluentProvider

final class Event: Model, NodeRepresentable {
    
    var name: String
    var shortDescription: String
    var status: EventStatus
    var userID: Identifier
    var startsAt: Date?
    var endsAt: Date?
    var languageRestriction: Language?
    var hasImage: Bool
    var scoringSystem: ScoringSystem
    var scoresHiddenBeforeEnd: Int
    
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
        shortDescription = try row.get("name")
        status = EventStatus(rawValue: try row.get("status")) ?? .draft
        userID = try row.get("user_id")
        startsAt = try row.get("starts_at")
        endsAt = try row.get("ends_at")
        if let languageRestriction = try row.get("language_restriction") as String? {
            self.languageRestriction = Language(rawValue: languageRestriction)
        }
        hasImage = try row.get("has_image")
        scoringSystem = ScoringSystem(rawValue: try row.get("scoring_system")) ?? .pointsThenLastCorrectSubmission
        scoresHiddenBeforeEnd = try row.get("scores_hidden_before_end")
    }
    
    init(name: String, userID: Identifier, startsAt: Date? = nil, endsAt: Date? = nil, languageRestriction: Language? = nil, status: EventStatus = .draft) {
        self.name = name
        self.shortDescription = ""
        self.status = status
        self.userID = userID
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.languageRestriction = languageRestriction
        self.hasImage = false
        self.scoringSystem = .pointsThenLastCorrectSubmission
        self.scoresHiddenBeforeEnd = 0
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("short_description", shortDescription)
        try row.set("status", status.rawValue)
        try row.set("user_id", userID)
        try row.set("starts_at", startsAt)
        try row.set("ends_at", endsAt)
        try row.set("language_restriction", languageRestriction?.rawValue)
        try row.set("has_image", hasImage)
        try row.set("scoring_system", scoringSystem.rawValue)
        try row.set("scores_hidden_before_end", scoresHiddenBeforeEnd)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id!.makeNode(in: context),
            "name": name.makeNode(in: context),
            "shortDescription": shortDescription,
            "status": status,
            "userID": userID.makeNode(in: context),
            "startsAt": startsAt?.makeNode(in: context) ?? "",
            "endsAt": endsAt?.makeNode(in: context) ?? "",
            "languageRestriction": languageRestriction ?? "",
            "hasImage": hasImage])
    }
    
    func isVisible(to user: User) -> Bool {
        return user.can(.teach) || isPubliclyVisible()
    }
    
    func isPubliclyVisible() -> Bool {
        return startsAt == nil || startsAt! < Date()
    }
    
}
