import Vapor
import FluentMySQL

final class Course: Content {
    
    var id: Int?
    var code: String
    var name: String
    var shortDescription: String
    var userID: User.ID
    var languageRestriction: Language?
    
    var topics: Children<Course, Topic> {
        return children(\.courseID)
    }
    
    init(id: Int? = nil, code: String, name: String, shortDescription: String = "", userID: Int, languageRestriction: Language? = nil) {
        self.id = id
        self.code = code
        self.name = name
        self.shortDescription = shortDescription
        self.userID = userID
        self.languageRestriction = languageRestriction
    }
    
    func isVisible(to user: User) -> Bool {
        return user.id == userID || user.can(.administrate)
    }

}

extension Course: MySQLModel {
    static let entity = "courses"
}

extension Course: Parameter {}
