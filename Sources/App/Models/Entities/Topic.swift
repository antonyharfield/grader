import Vapor
import FluentMySQL

final class Topic: Content {
    
    var id: Int?
    var name: String
    var description: String

    
    var topicItems: Children<Topic, TopicItem> {
        return children(\.topicID)
    }


    
    init(id: Int? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    
//    func isVisible(to user: User) -> Bool {
//        return user.id == userID || user.can(.administrate)
//    }
}

extension Topic: MySQLModel {
    static let entity = "topic"
}

extension Topic: Parameter {}
