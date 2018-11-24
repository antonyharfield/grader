import Vapor
import FluentMySQL

final class Course: Content {
    
    var id: Int?
    var code: String
    var name: String
    var shortDescription: String
    var status: PublishStatus
    var userID: User.ID
    var languageRestriction: Language?
    var joinCode: String?
    
    var topics: Children<Course, Topic> {
        return children(\.courseID)
    }
    
    init(id: Int? = nil, code: String, name: String, shortDescription: String = "", status: PublishStatus = .draft, userID: Int, languageRestriction: Language? = nil, joinCode: String) {
        self.id = id
        self.code = code
        self.name = name
        self.shortDescription = shortDescription
        self.status = status
        self.userID = userID
        self.languageRestriction = languageRestriction
        self.joinCode = joinCode
    }
    
    func isVisible(to user: User) -> Bool {
        return user.id == userID || user.can(.administrate)
    }
    
    func isEditable(to user: User) -> Bool {
        return user.id == userID || user.can(.administrate)
    }

}

extension Course: MySQLModel {
    static let entity = "courses"
}

extension Course: Parameter {}
