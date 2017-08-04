@_exported import Vapor
import AuthProvider
import Sessions

extension Droplet {
    public func setup() throws {
        
        let memory = MemorySessions()
        let sessionsMiddleware = SessionsMiddleware(memory)
        let persistMiddleware = PersistMiddleware(User.self)
        let guardMiddleware = GuardMiddleware(User.self)
        
        let openGroup = grouped([sessionsMiddleware, persistMiddleware])
        let protectedGroup = grouped([sessionsMiddleware, persistMiddleware, guardMiddleware])
        
        let routes = Routes(view)
        try openGroup.collection(routes)
        
        //let authedViewRenderer = AuthenticatedViewRenderer(view)
        let protectedRoutes = ProtectedRoutes(view)
        try protectedGroup.collection(protectedRoutes)
        
    }
}
