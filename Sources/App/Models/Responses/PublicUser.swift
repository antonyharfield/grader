import Vapor

struct PublicUser: Content {
    let id: Int?
    let name: String
    var email: String
    var username: String
    var role: Role
    var lastLogin: Date?
    var hasImage: Bool
}

extension PublicUser {
    func from(user: User) -> PublicUser {
        return PublicUser(id: user.id, name: user.name, email: user.email, username: user.username, role: user.role, lastLogin: user.lastLogin, hasImage: user.hasImage)
    }
}
