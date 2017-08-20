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
        
        return try view.make("events", wrapUserData([
            "events": events
        ], for: req), for: req)
    }
    
    /// GET /events/:id
    func show(_ request: Request, _ id: String) throws -> ResponseRepresentable {
        if request.auth.isAuthenticated(User.self) {
            return Response(redirect: "/events/\(id)/problems")
        }
        
        guard let event = try Event.find(id) else {
            throw Abort.notFound
        }
        
        let problems = try event.problems.all()
        return try view.make("event", wrapUserData([
            "event": event,
            "problems": problems
            ], for: request), for: request)
    }
    
    func makeResource() -> Resource<String> {
        return Resource(index: index, show: show)
    }
}
