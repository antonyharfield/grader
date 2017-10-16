import Foundation
import FluentProvider
import AuthProvider

final class User: Model {
    
    var name: String
    var email: String
    var username: String
    var password: String
    var role: Role
    var lastLogin: Date?
    var hasImage: Bool
    
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        email = try row.get("email")
        username = try row.get("username")
        password = try row.get("password")
        role = Role(rawValue: try row.get("role")) ?? .student
        lastLogin = try row.get("last_login")
        hasImage = try row.get("has_image")
    }
    
    init(name: String, email: String, username: String, password: String, role: Role) {
        self.name = name
        self.email = email
        self.username = username
        self.password = try! User.passwordHasher.make(password.makeBytes()).makeString()
        self.role = role
        self.lastLogin = nil
        self.hasImage = false
    }
    
    func setPassword(_ password: String) {
        self.password = try! User.passwordHasher.make(password.makeBytes()).makeString()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("email", email)
        try row.set("username", username)
        try row.set("password", password)
        try row.set("role", role.rawValue)
        try row.set("last_login", lastLogin)
        try row.set("has_image", hasImage)
        return row
    }
    
    func can(_ permissions: Permission...) -> Bool {
        return self.can(permissions)
    }
    
    func can(_ permissions: [Permission]) -> Bool {
        // true if ALL permissions are permitted
        return !permissions.lazy.map { self.role.permits($0) }.contains(false)
    }
    
}

extension User: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("name", name)
        try node.set("email", email)
        try node.set("username", username)
        try node.set("role", role.rawValue)
        try node.set("roleName", role.string)
        try node.set("lastLogin", lastLogin ?? "Never")
        try node.set("hasImage", hasImage)
        try node.set("color", PFColorHash().hex(name))
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

extension User {
    public static func passwordMeetsRequirements(_ proposedPassword: String) -> Bool {
        return proposedPassword.characters.count >= 4
    }
}

extension User: SessionPersistable { }

extension Request {
    var user: User? {
        return auth.authenticated(User.self)
    }
}
