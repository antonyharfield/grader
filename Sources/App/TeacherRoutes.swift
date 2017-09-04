import Vapor

final class TeacherRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
                
        let eventsController = EventsController(view)
        let problemsController = ProblemsController(view)
        
        builder.get("events/new", handler: eventsController.eventNew)
        builder.post("events/new", handler: eventsController.eventNewSubmit)
        
        builder.get("events", Event.parameter, "problems/new", handler: eventsController.eventProblemNew)
        builder.post("events", Event.parameter, "problems/new", handler: eventsController.eventProblemNewSubmit)
        
        builder.get("problems", Problem.parameter, "cases/new", handler: problemsController.problemCaseNew)
        builder.post("problems", Problem.parameter, "cases/new", handler: problemsController.problemCaseNewSubmit)
        
    }
}
