import Vapor
import Leaf
import FluentMySQL

extension EventsController: RouteCollection {
    func boot(router: Router) throws {
        router.get("/", use: index)
        router.get("events", Event.parameter, use: showProblemsPublic)
        router.get("events", Event.parameter, "image", use: image)
        router.get("events", Event.parameter, "problems", use: showProblems)
        router.get("events", Event.parameter, "submissions", use: showSubmissions)
        router.get("events", Event.parameter, "scores", use: showScores)
    }
}

final class EventsController {
    
    func index(request: Request) throws -> Future<View> {
        
        let activeEvents = Event.query(on: request).filter(\.status == .published).sort(\.id, .descending).all()
        //.filter(raw: "status = 2 AND (starts_at is null OR starts_at < CURRENT_TIMESTAMP) AND (ends_at is null OR ends_at > CURRENT_TIMESTAMP)")
        
        let pastEvents = Event.query(on: request).filter("status = 2 AND ends_at < CURRENT_TIMESTAMP").sort(\.id, .descending).all()
        
        let draftEvents: Future<[Event]>
        if try request.sessionIsAuthenticated() {
            draftEvents = request.sessionUser().unwrap(or: Abort(.internalServerError)).flatMap { user in
                    return Event.query(on: request).filter(\.status == .draft).filter(\.userID == user.id!).sort(\.id, .descending).all()
            }
        }
        else {
            draftEvents = request.eventLoop.newSucceededFuture(result: [])
        }

        let leaf = try request.make(LeafRenderer.self)
        let context = IndexViewContext(activeEvents: activeEvents, pastEvents: pastEvents, draftEvents: draftEvents)
        return leaf.render("Events/events", context, request: request)
    }
    
    func image(request: Request) throws -> Future<Response> {
        return try request.parameters.next(Event.self).flatMap { event in
            if !event.hasImage {
                throw Abort(HTTPResponseStatus.notFound)
            }
            let fileSystem = FileSystem()
            let eventPath = fileSystem.eventFilesPath(event: event)
            return try request.streamFile(at: eventPath + "graphic.png")
        }
    }
    
    func showProblemsPublic(request: Request) throws -> Future<Response> {
        if try request.sessionIsAuthenticated() {
            let id = request.parameters.values[0].value
            return request.eventLoop.newSucceededFuture(result: request.redirect(to: "/events/\(id)/problems"))
        }
        
        let eventFuture = try request.parameters.next(Event.self)
        return eventFuture.flatMap { event in
            
            guard event.isPubliclyVisible() else {
                throw Abort(.unauthorized)
            }
            
            let problemsFuture = try self.makeProblemsFuture(request: request, event: event)
            let context = ShowProblemsPublicViewContext(common: nil, event: eventFuture, problems: problemsFuture)
            let leaf = try request.make(LeafRenderer.self)
            return try leaf.render("Events/event-logged-out", context, request: request).encode(for: request)
        }
    }
    
    func showProblems(request: Request) throws -> Future<Response> {
        guard try request.sessionIsAuthenticated() else {
            let id = request.parameters.values[0].value
            return request.eventLoop.newSucceededFuture(result: request.redirect(to: "/events/\(id)"))
        }
        
        let eventFuture = try request.parameters.next(Event.self)
        let eventAndUserFuture = eventFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        let sql: String = [
            "SELECT p.*, ep.sequence, IFNULL(s.score,0) score, IFNULL(s.attempts,0) attempts",
            "FROM event_problems ep",
            "JOIN problems p ON ep.problemID = p.id",
            "LEFT JOIN (",
            "SELECT s.userID, s.eventProblemID, MAX(s.score) score, COUNT(1) attempts",
            "FROM submissions s",
            "GROUP BY userID, eventProblemID) s ON ep.id = s.eventProblemID AND s.userID = ?",
            "WHERE ep.eventID = ?",
            "ORDER BY ep.sequence"
            ].joined(separator: " ")

        return eventAndUserFuture.flatMap { (event, user) in
            guard event.isVisible(to: user) else {
                throw Abort(.unauthorized)
            }
            
            let problemsFuture = request.withPooledConnection(to: .mysql) { conn in
                return conn.query(sql, [user.id!, event.id!])
            }
            let userProblemsFuture = problemsFuture.map { problems in
                return try problems.map { try UserEventProblem(row: $0) }
            }
            
            let context = ProblemsViewContext(common: nil, event: eventFuture, problems: userProblemsFuture)
            let leaf = try request.make(LeafRenderer.self)
            return try leaf.render("Events/event", context, request: request).encode(for: request)
        }

    }
    
    private func makeProblemsFuture(request: Request, event: Event) throws -> Future<[PublicEventProblem]> {
        return try event.eventProblems.query(on: request).sort(\.sequence)
            .join(\Problem.id, to: \EventProblem.problemID).alsoDecode(Problem.self).all()
            .map { problems in
                return problems.map { PublicEventProblem(eventProblem: $0.0, problem: $0.1) }
        }
    }
    
    func showSubmissions(request: Request) throws -> Future<Response> {
        throw Abort(.notImplemented)
    }
    
    func showScores(request: Request) throws -> Future<Response> {
        throw Abort(.notImplemented)
    }
}

fileprivate struct IndexViewContext: ViewContext {
    var common: CommonViewContext?
    let activeEvents: Future<[Event]>
    let pastEvents: Future<[Event]>
    let draftEvents: Future<[Event]>
    init(activeEvents: Future<[Event]>, pastEvents: Future<[Event]>, draftEvents: Future<[Event]>) {
        self.activeEvents = activeEvents
        self.pastEvents = pastEvents
        self.draftEvents = draftEvents
    }
}

fileprivate struct ShowProblemsPublicViewContext: ViewContext {
    var common: CommonViewContext?
    let event: Future<Event>
    let problems: Future<[PublicEventProblem]>
}

fileprivate struct ProblemsViewContext: ViewContext {
    var common: CommonViewContext?
    let event: Future<Event>
    let problems: Future<[UserEventProblem]>
}

extension UserEventProblem {
    init(row: [MySQLColumn: MySQLData]) throws {
        let problemID = try row.firstValue(forColumn: "id")!.decode(Int.self)
        let problemName = try row.firstValue(forColumn: "name")!.decode(String.self)
        let problemDescription = try row.firstValue(forColumn: "description")!.decode(String.self)
        let problem = Problem(id: problemID, name: problemName, description: problemDescription)
        
        let sequence = try row.firstValue(forColumn: "sequence")!.decode(Int.self)
        let score = try row.firstValue(forColumn: "score")!.decode(Int.self)
        let attempts = try row.firstValue(forColumn: "attempts")!.decode(Int.self)
        
        self.init(id: 0, sequence: sequence, problem: problem, score: score, attempts: attempts)
    }
}
