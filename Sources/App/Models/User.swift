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
    
    func setPassword(_ password: String) {
        self.password = try! User.passwordHasher.make(password.makeBytes()).makeString()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("username", username)
        try row.set("password", password)
        try row.set("role", role.rawValue)
        return row
    }
}

extension User: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id?.string ?? "")
        try node.set("name", name)
        try node.set("username", username)
        try node.set("role", role.rawValue)
        return node
    }
}


extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("username")
            builder.string("password")
            builder.int("role")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
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
