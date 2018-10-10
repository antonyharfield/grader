import Vapor
import FluentMySQL

final class AchievementUser: Content {
    
    var id: Int?
    var achievementID: Int
    var userID: Int
    
    
    
    init(id: Int? = nil, achievementID: Int, userID: Int) {
        self.id = id
        self.achievementID = achievementID
        self.userID = userID
    }
}

extension AchievementUser: MySQLModel {
    static let entity = "achievement_users"
}

extension AchievementUser: Pivot {
    typealias Left = Achievement
    typealias Right = AchievementUser
    static let leftIDKey: LeftIDKey = \.achievementID
    static let rightIDKey: RightIDKey = \.userID
}