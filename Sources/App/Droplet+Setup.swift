@_exported import Vapor
import AuthProvider
import Sessions
import LeafProvider

extension Droplet {
    
    public func setup() throws {
        
        addLeafTags()
        
        let memory = MemorySessions()
        let sessionsMiddleware = SessionsMiddleware(memory)
        let persistMiddleware = PersistMiddleware(User.self)
        let guardMiddleware = GuardMiddleware(User.self)
        
        let openGroup = grouped([sessionsMiddleware, persistMiddleware])
        let protectedGroup = grouped([sessionsMiddleware, persistMiddleware, guardMiddleware])
        
        let routes = Routes(view)
        try openGroup.collection(routes)
        
        let protectedRoutes = ProtectedRoutes(view)
        try protectedGroup.collection(protectedRoutes)
        
    }
    
    private func addLeafTags() {
        if let leaf = view as? LeafRenderer {
            leaf.stem.register(ArrayContains())
            leaf.stem.register(Add())
        }
    }
}
