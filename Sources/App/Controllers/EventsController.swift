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
        let activeEvents = try Event.makeQuery().filter(raw: "(starts_at is null OR starts_at < CURRENT_TIMESTAMP) AND (ends_at is null OR ends_at > CURRENT_TIMESTAMP)").all()
        let pastEvents = try Event.makeQuery().filter(raw: "ends_at < CURRENT_TIMESTAMP").all()
        
        return try render("Events/events", ["activeEvents": activeEvents, "pastEvents": pastEvents], for: req, with: view)
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
        return try render("Events/event-logged-out", ["event": event, "problems": problems], for: request, with: view)
    }
    
    func makeResource() -> Resource<String> {
        return Resource(index: index, show: show)
    }
    
    /// GET /events/new
    func eventNew(request: Request) throws -> ResponseRepresentable {
        return try render("Events/Teacher/event-new", for: request, with: view)
    }
    
    /// POST /events/new
    func eventNewSubmit(request: Request) throws -> ResponseRepresentable {
        guard
            let userId = request.user?.id,
            let name = request.data["name"]?.string
        else {
            throw Abort.badRequest
        }

        // Extract
        // TBD: How do we handle invalid dates? (I think I'm just consuming them as nil)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let startsAt = request.data["starts_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["starts_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }
        
        let endsAt = request.data["ends_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["ends_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }
        
        let languageRestriction = request.data["language_restriction"]?.string.flatMap { raw in Language(rawValue: raw) }

        // Save & continue
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
    
    /// GET /events/:id/problems/new
    func eventProblemNew(request: Request) throws -> ResponseRepresentable {
        return try render("Events/Teacher/event-problem-new", for: request, with: view)
    }

    /// POST /events/:id/problems/new
    func eventProblemNewSubmit(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        
        guard
            let eventId = event.id,
            let name = request.data["name"]?.string,
            let description = request.data["description"]?.string,
            let comparisonMethodRaw = request.data["comparison_method"]?.string,
            let comparisonMethod = ComparisonMethod(rawValue: comparisonMethodRaw)
        else {
            throw Abort.badRequest
        }

        // Extract
        // TBD: Probably need a better way to define sequence
        let seq = try EventProblem.makeQuery()
            .filter(EventProblem.self, "event_id", eventId).count() + 1

        let comparisonIgnoreSpaces = (request.data["comparison_ignore_spaces"]?.string == "true")
        let comparisonIgnoreBreaks = (request.data["comparison_ignore_breaks"]?.string == "true")
        
        // Save & continue
        let problem = Problem(name: name, description: description, comparisonMethod: comparisonMethod, comparisonIgnoresSpaces: comparisonIgnoreSpaces, comparisonIgnoresBreaks: comparisonIgnoreBreaks)
        try problem.save()
        
        let eventProblem = EventProblem(eventID: eventId, problemID: problem.id!, sequence: seq)
        try eventProblem.save()
        
        return Response(redirect: "/problems/\(problem.id!.string!)/cases/new")
    }
    
}
