import Foundation
import FluentProvider
import AuthProvider

enum Role: Int {
    case student = 1
    case teacher = 2
    case admin = 3
}

final class User: Model {
    
    var name: String
    var username: String
    var password: String
    var role: Role
    
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        username = try row.get("username")
        password = try row.get("password")
        role = Role(rawValue: try row.get("role")) ?? .student
    }
    
    init(name: String, username: String, password: String, role: Role) {
        self.name = name
        self.username = username
        self.password = try! User.passwordHasher.make(password.makeBytes()).makeString()
        self.role = role
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("username", username)
        try row.set("password", password)
        try row.set("role", role.rawValue)
        return row
    }
    
    func has(role: Role) -> Bool {
        switch role {
        case .admin:
            return self.role == .admin
        case .teacher:
            return self.role == .teacher || self.role == .admin
        case .student:
            return true
        }
    }
}

extension User: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("name", name)
        try node.set("username", username)
        try node.set("role", role.rawValue)
        return node
    }
}

extension User: PasswordAuthenticatable {
    public static let usernameKey = "username"
    public static let passwordVerifier: PasswordVerifier? = User.passwordHasher
    public var hashedPassword: String? {
        return password
    }
    public static let passwordHasher = BCryptHasher(cost: 10)
}

extension User: SessionPersistable { }

extension Request {
    var user: User? {
        return auth.authenticated(User.self)
    }
}
