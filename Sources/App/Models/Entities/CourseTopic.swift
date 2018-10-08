import Vapor
import FluentMySQL

final class CourseTopic: Content {
    
    var id: Int?
    var courseID: Int
    var topicID: Int
    var sequence: Int
    
    var course: Parent<CourseTopic, Course> {
        return parent(\.courseID)
    }
    
    var topic: Parent<CourseTopic, Topic> {
        return parent(\.topicID)
    }
  
    init(id: Int? = nil, courseID: Int, topicID: Int, sequence: Int) {
        self.id = id
        self.courseID = courseID
        self.topicID = topicID
        self.sequence = sequence
    }
}

extension CourseTopic: MySQLModel {
    static let entity = "course_topics"
}

extension CourseTopic: Pivot {
    typealias Left = Course
    typealias Right = Topic
    static let leftIDKey: LeftIDKey = \.courseID
    static let rightIDKey: RightIDKey = \.topicID
}
