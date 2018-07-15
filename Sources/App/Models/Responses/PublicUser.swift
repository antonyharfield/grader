import Vapor

struct PublicUser: Content {
    let id: Int?
    let name: String
    let email: String
    let username: String
    let role: Role
    let lastLogin: Date?
    let hasImage: Bool
    let color: String
}

extension PublicUser {
    init(user u: User) {
        self.init(id: u.id, name: u.name, email: u.email, username: u.username, role: u.role, lastLogin: u.lastLogin, hasImage: u.hasImage, color: PublicUser.colorFor(name: u.name))
    }
    
    static func colorFor(name: String) -> String {
        return "#"+PFColorHash().hex(name)
    }
}
