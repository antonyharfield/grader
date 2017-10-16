import Vapor

final class ProtectedRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        let profileController = ProfileController(view)
        builder.get("profile", handler: profileController.profile)
        builder.get("profile/image", handler: profileController.image)
        builder.get("profile/edit", handler: profileController.editForm)
        builder.post("profile/edit", handler: profileController.edit)
        builder.get("changepassword", handler: profileController.changePasswordForm)
        builder.post("changepassword", handler: profileController.changePassword)
        builder.get("logout", handler: profileController.logout)
        
        let problemsController = ProblemsController(view)
        builder.get("events", Event.parameter, "problems", handler: problemsController.problems)
        builder.get("events", Event.parameter, "submissions", handler: problemsController.submissions)
        builder.get("events", Event.parameter, "scores", handler: problemsController.scores)
        
        builder.get("events", Event.parameter, "problems", Int.parameter, handler: problemsController.form)
        builder.post("events", Event.parameter, "problems", Int.parameter, handler: problemsController.submit)
    }
}

