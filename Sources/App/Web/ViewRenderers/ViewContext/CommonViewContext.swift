import Vapor

struct CommonViewContext: Service, Content {
    let authenticated: Bool
    let user: User?
    let canAdministrate: Bool
    let canTeach: Bool
    let path: String
    let pathComponents: [String]
    
    init(user: User?, url: URL) {
        self.user = user
        if let user = user {
            self.authenticated = true
            self.canAdministrate = user.can(.administrate)
            self.canTeach = user.can(.teach)
        }
        else {
            self.authenticated = false
            self.canAdministrate = false
            self.canTeach = false
        }
        self.path = url.path
        self.pathComponents = url.pathComponents
    }
}
