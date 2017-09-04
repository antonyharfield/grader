import Foundation
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
    func eventNew(request: Request) throws -> ResponseRepresentable {
        return try render("Teacher/event-new", for: request, with: view)
    }
    
    func eventNewSubmit(request: Request) throws -> ResponseRepresentable {
        guard
            let userId = request.user?.id,
            let name = request.data["name"]?.string
        else {
            throw Abort.badRequest
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        // TBD: How do we handle invalid dates? (I think I'm just consuming them as nil)
        let startsAt = request.data["starts_at"]?.string.flatMap { raw in formatter.date(from: raw) }
        let endsAt = request.data["ends_at"]?.string.flatMap { raw in formatter.date(from: raw) }
        let languageRestriction = request.data["language_restriction"]?.string.flatMap { raw in Language(rawValue: raw) }
        
        let event = Event(
            name: name,
            userID:userId,
            startsAt: startsAt,
            endsAt: endsAt,
            languageRestriction: languageRestriction
        )
        try event.save()
        
        return Response(redirect: "/events/\(event.id!.string!)/problems/new")
    }
    
    func eventProblemNew(request: Request) throws -> ResponseRepresentable {
        return "PLACEHOLDER"
    }

    func eventProblemNewSubmit(request: Request) throws -> ResponseRepresentable {
        return "PLACEHOLDER"
    }

}
