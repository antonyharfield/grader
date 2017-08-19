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
        
        return try view.make("event-problems", wrapUserData([
            "event": event,
            "problems": problems
            ], for: request), for: request)
    }
    
    /// GET /events/:id/submissions
    func submissions(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        
        return try view.make("submissions", wrapUserData([
            "event": event
            ], for: request), for: request)
    }
    
    /// GET /events/:id/scores
    func scores(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        
        return try view.make("scores", wrapUserData([
            "event": event
            ], for: request), for: request)
    }
    
    /// GET /events/:id/problems/:seq
    func form(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let sequence = try request.parameters.next(Int.self)
        
        guard let eventProblem = try event.eventProblems.filter("order", sequence).first(),
            let problem = try eventProblem.problem.get() else {
                throw Abort.notFound
        }
        
        return try view.make("problem-form", wrapUserData([
            "event": event,
            "eventProblem": eventProblem,
            "problem": problem
            ], for: request), for: request)
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
