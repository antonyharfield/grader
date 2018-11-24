import Vapor
import FluentMySQL

final class Topic: Content {
    
    var id: Int?
    var courseID: Int
    var sequence: Int
    var name: String
    var description: String
    var hidden: Bool

    var topicItems: Children<Topic, TopicItem> {
        return children(\.topicID)
    }
    
    var course: Parent<Topic, Course> {
        return parent(\.courseID)
    }

    
    init(id: Int? = nil, courseID: Int, sequence: Int, name: String, description: String, hidden: Bool = false) {
        self.id = id
        self.courseID = courseID
        self.sequence = sequence
        self.name = name
        self.description = description
        self.hidden = hidden
    }
}

extension Topic: MySQLModel {
    static let entity = "topic"
}

extension Topic: Parameter {}
