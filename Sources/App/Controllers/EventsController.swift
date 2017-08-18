import Vapor
import HTTP

final class EventsController: ResourceRepresentable {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /events
    func index(_ req: Request) throws -> ResponseRepresentable {

        let events = try Event.all()
        
        return try view.make("events", [
            "events": events
            ], for: req)
    }
    
    /// GET /events/:id
    func show(_ req: Request, _ id: String) throws -> ResponseRepresentable {
        
        if let event = try Event.find(id) {
            let problems = try Problem.all() // TODO: get only event problems
            return try view.make("event", [
                "event": event,
                "problems": problems
                ], for: req)
        }
        
        throw Abort.notFound
    }
    
    func makeResource() -> Resource<String> {
        return Resource(index: index, show: show)
    }
}
