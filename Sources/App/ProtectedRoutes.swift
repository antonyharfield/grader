import Vapor

final class ProtectedRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        let userController = UsersController(view)
        builder.get("users", handler: userController.showUser)
        builder.get("users", Int.parameter, "edit", handler: userController.editForm)
        builder.post("users", Int.parameter, "edit", handler: userController.edit)
        
        builder.get("users", Int.parameter,"delete", handler: userController.deleteForm)
        builder.post("users", Int.parameter,"delete", handler: userController.delete)
        
        builder.get("logout", handler: userController.logout)
        
        let problemsController = ProblemsController(view)
        builder.get("events", Event.parameter, "problems", handler: problemsController.problems)
        builder.get("events", Event.parameter, "submissions", handler: problemsController.submissions)
        builder.get("events", Event.parameter, "scores", handler: problemsController.scores)
        
        builder.get("events", Event.parameter, "problems", Int.parameter, handler: problemsController.form)
        builder.post("events", Event.parameter, "problems", Int.parameter, handler: problemsController.submit)
        
    }
}
