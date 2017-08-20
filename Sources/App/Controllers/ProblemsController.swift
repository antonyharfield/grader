import Vapor
import HTTP

final class ProblemsController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /events/:id/problems
    func problems(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let problems = try event.eventProblems.sort("sequence", .ascending).all()
        
        return try render("event-problems", [
            "event": event,
            "problems": problems
            ], for: request, with: view)
    }
    
    /// GET /events/:id/submissions
    func submissions(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let submissions = try Submission.makeQuery().join(EventProblem.self, baseKey: "event_problem_id", joinedKey: "id")
            .filter(EventProblem.self, "event_id", event.id).sort("created_at", .descending).all()
        
        return try render("submissions", [
            "event": event,
            "submissions": submissions
            ], for: request, with: view)
    }
    
    /// GET /events/:id/scores
    func scores(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        
        return try render("scores", [
            "event": event
            ], for: request, with: view)
    }
    
    /// GET /events/:id/problems/:seq
    func form(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let sequence = try request.parameters.next(Int.self)
        
        guard let eventProblem = try event.eventProblems.filter("order", sequence).first(),
            let problem = try eventProblem.problem.get() else {
                throw Abort.notFound
        }
        
        return try render("problem-form", [
            "event": event,
            "eventProblem": eventProblem,
            "problem": problem
            ], for: request, with: view)
    }
    
    /// POST /events/:id/problems/:seq
    func submit(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let sequence = try request.parameters.next(Int.self)
        
        guard let eventProblem = try event.eventProblems.filter("order", sequence).first(),
            let problem = try eventProblem.problem.get() else {
                throw Abort.notFound
        }
        
        return Response(redirect: "/events/\(event.id!)/submissions")
    }

}
