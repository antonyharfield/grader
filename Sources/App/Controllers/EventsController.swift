import Vapor
import HTTP

final class EventsController: ResourceRepresentable {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /events
    func index(_ req: Request) throws -> ResponseRepresentable {

        let activeEvents = try Event.makeQuery().filter(raw: "ends_at is null").all()
        let pastEvents = try Event.makeQuery().filter(raw: "ends_at < CURRENT_TIMESTAMP").all()
        
        return try render("events", ["activeEvents": activeEvents, "pastEvents": pastEvents], for: req, with: view)
    }
    
    /// GET /events/:id
    func show(_ request: Request, _ id: String) throws -> ResponseRepresentable {
        if request.auth.isAuthenticated(User.self) {
            return Response(redirect: "/events/\(id)/problems")
        }
        
        guard let event = try Event.find(id) else {
            throw Abort.notFound
        }
        
        let problems = try event.eventProblems.sort("sequence", .ascending).all()
        return try render("event", ["event": event, "problems": problems], for: request, with: view)
    }
    
    func makeResource() -> Resource<String> {
        return Resource(index: index, show: show)
    }
    
    /// GET /events/new
    func new(request: Request) throws -> ResponseRepresentable {
        return try render("event-new", for: request, with: view)
    }
    
}
