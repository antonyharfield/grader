import Vapor

final class ProtectedRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        let usersController = UsersController(view)
        builder.get("logout", handler: usersController.logout)
        
        /// GET /problems/...
        builder.resource("problems", ProblemsController(view))
        
    }
}

func wrapUserData(_ dict: [String: Any], for request: HTTP.Request) -> [String: Any] {
    guard let user = request.user else {
        fatalError("No user found")
    }
    var result = dict
    result["authenticated"] = true
    result["user"] = user
    return result
}
