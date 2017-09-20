import Vapor

final class TeacherRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        let eventsController = EventsController(view)
        let problemsController = ProblemsController(view)
        let submissionsController = SubmissionsController(view)
        
        
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
        
        
        /// PROBLEM CASE
        
        // problems/:id/cases/new (obsolete)
        builder.get("problems", Problem.parameter, "cases/new", handler: problemsController.problemCaseNew)
        builder.post("problems", Problem.parameter, "cases/new", handler: problemsController.problemCaseNewSubmit)
        
        
        /// SUBMISSION
        
        // submissions/:id/run
        builder.post("submissions", Submission.parameter, "run", handler: submissionsController.manualRun)
    }
}
