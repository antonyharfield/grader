import Vapor
import FluentMySQL

final class Achievement: Content {
    
    var id: Int?
    var name: String
    var shortDescription: String
    var sequence: Int

    
    init(id: Int? = nil, name: String, shortDescription: String = "", sequence: Int) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.sequence = sequence
        
    }
}

extension Achievement: MySQLModel {
    static let entity = "achievements"
}

extension Achievement: Parameter {}
