import Vapor

struct CommonViewContext: Service, Content {
    let authenticated: Bool
    let authenticatedUser: User?
    let path: String
    let pathComponents: [String]
}
