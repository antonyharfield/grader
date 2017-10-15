import Vapor

final class TeacherRoutes: RouteCollection {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    func build(_ builder: RouteBuilder) throws {
        let eventsController = EventsController(view)
        let submissionsController = SubmissionsController(view)
        let userController = UsersController(view)
        let loginController = LoginController(view)

        /// EVENTS

        // events/new
        builder.get("events/new", handler: eventsController.eventNew)
        builder.post("events/new", handler: eventsController.eventNewSubmit)

        /// EVENT

        // events/:id/problems/new
        builder.get("events", Event.parameter, "problems/new", handler: eventsController.eventProblemNew)
        builder.post("events", Event.parameter, "problems/new", handler: eventsController.eventProblemNewSubmit)

        // events/:id/problems/:seq/edit
        builder.get("events", Event.parameter, "problems", ":eventProblemSeq", "edit", handler: eventsController.eventProblemEdit)
        builder.post("events", Event.parameter, "problems", ":eventProblemSeq", "edit", handler: eventsController.eventProblemNewSubmit)

        /// SUBMISSION

        // submissions/:id/run
        builder.post("submissions", Submission.parameter, "run", handler: submissionsController.manualRun)

        builder.get("events", Event.parameter, "edit", handler: eventsController.eventEditForm)
        builder.post("events", Event.parameter, "edit", handler: eventsController.eventEdit)

        /// USER MANAGEMENT

        builder.get("users", handler: userController.showUser)
        builder.get("users", Int.parameter, "edit", handler: userController.editForm)
        builder.post("users", Int.parameter, "edit", handler: userController.edit)
        builder.get("users", Int.parameter, "delete", handler: userController.deleteForm)
        builder.post("users", Int.parameter, "delete", handler: userController.delete)
    }
}
