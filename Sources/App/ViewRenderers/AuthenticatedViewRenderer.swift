import Vapor

/// NOT USED

class AuthenticatedViewRenderer: ViewRenderer {
    
    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    var shouldCache: Bool {
        get {
            return view.shouldCache
        }
        set {
            view.shouldCache = newValue
        }
    }
    
    func make(_ path: String, _ data: ViewData) throws -> View {
        return try view.make(path, data)
    }
    
    func make(_ path: String, _ context: Node) throws -> View {
        return try view.make(path, context)
    }
    
    public func make(_ path: String, for request: HTTP.Request) throws -> Vapor.View {
        return try make(path, [], for: request)
    }
    
    public func make(_ path: String, _ context: NodeRepresentable, for request: HTTP.Request) throws -> Vapor.View {
        guard let user = request.user else {
            fatalError("No user found")
        }
        var dict = (context as? [String: Any]) ?? [:]
        dict["authenticated"] = true
        dict["user"] = user
        return try view.make(path, dict, for: request)
    }
    
}
