import Vapor

final class TeacherRoutes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
                
        let eventsController = EventsController(view)
        builder.get("events/new", handler: eventsController.new)
        
    }
}
