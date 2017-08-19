import Vapor

final class ProtectedRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        let usersController = UsersController(view)
        builder.get("logout", handler: usersController.logout)
        
        let problemsController = ProblemsController(view)
        builder.get("events", Event.parameter, "problems", handler: problemsController.problems)
        builder.get("events", Event.parameter, "submissions", handler: problemsController.problems)
        builder.get("events", Event.parameter, "scores", handler: problemsController.problems)
        
        builder.get("events", Event.parameter, "problems", Int.parameter, handler: problemsController.form)
        builder.post("events", Event.parameter, "problems", Int.parameter, handler: problemsController.submit)
        
    }
}

func wrapUserData(_ dict: [String: Any], for request: HTTP.Request) -> [String: Any] {
    guard let user = request.user else {
        return dict
    }
    var result = dict
    result["authenticated"] = true
    result["user"] = user
    return result
}
