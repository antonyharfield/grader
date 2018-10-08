import Vapor
import FluentMySQL

final class TopicItem: Content {
    
    var id: Int?
    var topicID: Int
    var problemID: Int?
    var name: String
    var text: String
    var sequence: Int
  
    var problem: Parent<TopicItem, Problem>?{
        return parent(\.problemID)
    }
    
    init(id: Int? = nil, topicID: Int, problemID: Int? = nil, name: String, text: String, sequence: Int) {
        self.id = id
        self.topicID = topicID
        self.problemID = problemID
        self.name = name
        self.text = text
        self.sequence = sequence
    }
}

extension TopicItem: MySQLModel {
    static let entity = "topic_items"
}

extension TopicItem: Parameter {}


