import Vapor
import FluentMySQL

final class CourseMember: Content {
    
    var id: Int?
    var courseID: Int
    var userID: Int
    var role: Role
    
    init(id: Int? = nil, courseID: Int, userID: Int, role: Role) {
        self.id = id
        self.courseID = courseID
        self.userID = userID
        self.role = role
    }
}

extension CourseMember: MySQLModel {
    static let entity = "course_members"
}

extension CourseMember: Pivot {
    typealias Left = Course
    typealias Right = User
    static let leftIDKey: LeftIDKey = \.courseID
    static let rightIDKey: RightIDKey = \.userID
}
