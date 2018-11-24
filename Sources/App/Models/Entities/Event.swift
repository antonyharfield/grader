import Vapor
import FluentMySQL

final class Event: Content {

    var id: Int?
    var name: String
    var shortDescription: String
    var status: PublishStatus
    var userID: User.ID
    var startsAt: Date?
    var endsAt: Date?
    var languageRestriction: Language?
    var hasImage: Bool
    var scoringSystem: ScoringSystem
    var scoresHiddenBeforeEnd: Int
    
    var user: Parent<Event, User> {
        return parent(\.userID)
    }
    var eventProblems: Children<Event, EventProblem> {
        return children(\.eventID)
    }
    var problems: Siblings<Event, Problem, EventProblem> {
        return siblings()
    }
    
    init(id: Int? = nil, name: String, shortDescription: String = "", status: PublishStatus = .draft, userID: Int, startsAt: Date? = nil, endsAt: Date? = nil, languageRestriction: Language? = nil, hasImage: Bool = false, scoringSystem: ScoringSystem = .default, scoresHiddenBeforeEnd: Int = 0) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.status = status
        self.userID = userID
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.languageRestriction = languageRestriction
        self.hasImage = hasImage
        self.scoringSystem = scoringSystem
        self.scoresHiddenBeforeEnd = scoresHiddenBeforeEnd
    }
    
    func isVisible(to user: User) -> Bool {
        return isPubliclyVisible() || user.id == userID || user.can(.administrate)
    }
    
    func isPubliclyVisible() -> Bool {
        return startsAt == nil || startsAt! < Date()
    }
    
}

extension Event: MySQLModel {
    static let entity = "events"
}

extension Event: Parameter {}
