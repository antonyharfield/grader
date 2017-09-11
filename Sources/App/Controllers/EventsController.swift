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
    
    /// GET /events/:id/problems/:seq/edit
    func eventProblemEdit(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let eventProblemSeq = request.parameters["eventProblemSeq"]!
        let eventProblem = try EventProblem.makeQuery()
            .filter(EventProblem.self, "event_id", event.id)
            .filter(EventProblem.self, "sequence", eventProblemSeq)
            .first()!
        
        let problem = try eventProblem.problem.get()!
        let cases = try problem.cases.all()
        return try render("Events/Teacher/event-problem-new", ["eventProblem": eventProblem, "problem": problem, "cases": cases], for: request, with: view)
    }

    /// POST /events/:id/problems/new
    /// POST /events/:id/problems/:seq/edit
    func eventProblemNewSubmit(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        
        // Extract
        guard
            let eventId = event.id,
            let name = request.data["name"]?.string,
            let description = request.data["description"]?.string,
            let comparisonMethodRaw = request.data["comparison_method"]?.string,
            let comparisonMethod = ComparisonMethod(rawValue: comparisonMethodRaw)
        else {
            throw Abort.badRequest
        }
        
        let comparisonIgnoreSpaces = (request.data["comparison_ignore_spaces"]?.string == "true")
        let comparisonIgnoreBreaks = (request.data["comparison_ignore_breaks"]?.string == "true")
        
        // Save & continue
        let eventProblemSeq = request.parameters["eventProblemSeq"]
        let eventProblem: EventProblem
        if(eventProblemSeq == nil) {
            // New
            let problem = Problem(name: name, description: description, comparisonMethod: comparisonMethod, comparisonIgnoresSpaces: comparisonIgnoreSpaces, comparisonIgnoresBreaks: comparisonIgnoreBreaks)
            try problem.save()
            
            // TBD: Probably need a better way to define sequence
            let seq = try EventProblem.makeQuery()
                .filter(EventProblem.self, "event_id", eventId).count() + 1

            eventProblem = EventProblem(eventID: eventId, problemID: problem.id!, sequence: seq)
            try eventProblem.save()
        } else {
            // Edit
            eventProblem = try EventProblem.makeQuery()
                .filter(EventProblem.self, "event_id", event.id)
                .filter(EventProblem.self, "sequence", eventProblemSeq!)
                .first()!
            
            let problem = try eventProblem.problem.get()!
            problem.name = name
            problem.description = description
            problem.comparisonMethod = comparisonMethod
            problem.comparisonIgnoresSpaces = comparisonIgnoreSpaces
            problem.comparisonIgnoresBreaks = comparisonIgnoreBreaks
            try problem.save()
            
        }

        return Response(redirect: "/events/\(eventId.string!)/problems/\(eventProblem.sequence)")
    }
    
}
