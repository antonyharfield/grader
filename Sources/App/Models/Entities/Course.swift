import Vapor
import FluentMySQL

final class Course: Content {
    
    var id: Int?
    var name: String
    var shortDescription: String
    var sequence: Int
    var userID: User.ID
    
    var courseTopics: Children<Course, CourseTopic> {
        return children(\.courseID)
    }
    var topics: Siblings<Course, Topic, CourseTopic> {
        return siblings()
    }
    
    init(id: Int? = nil, name: String, shortDescription: String = "", sequence: Int, userID: Int) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.sequence = sequence
        self.userID = userID
    }
    
    func isVisible(to user: User) -> Bool {
        return user.id == userID || user.can(.administrate)
    }

}

extension Course: MySQLModel {
    static let entity = "courses"
}

extension Course: Parameter {}
