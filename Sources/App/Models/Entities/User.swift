import Authentication
import FluentMySQL
import Vapor

final class User: Content {
    
    var id: Int?
    var name: String
    var email: String
    var username: String
    var password: String
    var role: Role
    var lastLogin: Date?
    var hasImage: Bool
    
    var courses: Siblings<User, Course, CourseMember> {
        return siblings()
    }
    
    init(id: Int? = nil, name: String, email: String, username: String, password: String, role: Role = .student, lastLogin: Date? = nil, hasImage: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.username = username
        self.password = password
        self.role = role
        self.lastLogin = lastLogin
        self.hasImage = hasImage
    }
    
    func can(_ permissions: Permission...) -> Bool {
        return self.can(permissions)
    }
    
    func can(_ permissions: [Permission]) -> Bool {
        // true if ALL permissions are permitted
        return !permissions.lazy.map { self.role.permits($0) }.contains(false)
    }
    
}

extension User: MySQLModel {
    static let entity = "users"
}

extension User {
    public static func passwordMeetsRequirements(_ proposedPassword: String) -> Bool {
        return proposedPassword.count >= 4
    }
}

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> { return \User.username }
    static var passwordKey: WritableKeyPath<User, String> { return \User.password }
}

extension User: SessionAuthenticatable {}

