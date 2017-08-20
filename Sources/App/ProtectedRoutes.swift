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
        builder.get("events", Event.parameter, "submissions", handler: problemsController.submissions)
        builder.get("events", Event.parameter, "scores", handler: problemsController.scores)
        
        builder.get("events", Event.parameter, "problems", Int.parameter, handler: problemsController.form)
        builder.post("events", Event.parameter, "problems", Int.parameter, handler: problemsController.submit)
        
    }
}
