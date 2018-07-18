import Vapor
import Leaf
import FluentMySQL

extension EventsController: RouteCollection {
    func boot(router: Router) throws {
        router.get("/", use: index)
        router.get("events", Event.parameter, use: showProblemsPublic)
        router.get("events", Event.parameter, "image", use: image)
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("events", Event.parameter, "problems", use: showProblems)
        authedRouter.get("events", Event.parameter, "submissions", use: showSubmissions)
        authedRouter.get("events", Event.parameter, "scores", use: showRankings)
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
            let fileSystem = FileSystem()
            let imagePath = fileSystem.eventFilesPath(event: event) + "graphic.png"
            guard event.hasImage, fileSystem.fileExists(at: imagePath) else {
                throw Abort(HTTPResponseStatus.notFound)
            }
            return try request.streamFile(at: imagePath)
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
            
            let problemsFuture = try event.eventProblems.query(on: request).sort(\.sequence)
                .join(\Problem.id, to: \EventProblem.problemID).alsoDecode(Problem.self).all()
                .map { problems in
                    return problems.map { PublicEventProblem(eventProblem: $0.0, problem: $0.1) }
            }
            let context = ShowProblemsPublicViewContext(common: nil, event: eventFuture, problems: problemsFuture)
            let leaf = try request.make(LeafRenderer.self)
            return try leaf.render("Events/event-logged-out", context, request: request).encode(for: request)
        }
    }
    
    func showProblems(request: Request) throws -> Future<Response> {
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
    
    func showSubmissions(request: Request) throws -> Future<View> {
        let id = Int(request.parameters.values[0].value)!
        
        let eventFuture = try request.parameters.next(Event.self)
        let eventAndUserFuture = eventFuture.and(try request.requireSessionUser())
        
        let contextFuture = eventAndUserFuture.map { (event, user) -> SubmissionsViewContext in
            
            guard event.isVisible(to: user) else {
                throw Abort(.unauthorized)
            }
            
            var query = Submission.query(on: request).sort(\.createdAt, .descending)
                .join(\EventProblem.id, to: \Submission.eventProblemID).alsoDecode(EventProblem.self)
                .join(\Problem.id, to: \EventProblem.problemID).alsoDecode(Problem.self)
                .join(\User.id, to: \Submission.userID).alsoDecode(User.self)
                .filter(\EventProblem.eventID == id)
            if user.role == .student {
                query = query.filter(\Submission.userID == user.id!)
            }

            let submissionsFuture = query.all().map { rows -> [PublicSubmission] in
                return rows.map { row in
                    return PublicSubmission(submission: row.0.0.0, eventProblem: row.0.0.1, problem: row.0.1, user: row.1)
                }
            }

            let completedEventFuture = request.eventLoop.newSucceededFuture(result: event)
            return SubmissionsViewContext(common: nil, event: completedEventFuture, submissions: submissionsFuture)
        }
            
        return contextFuture.flatMap { context in
            let leaf = try request.make(LeafRenderer.self)
            return leaf.render("Events/submissions", context, request: request)
        }
    }
    
    func showRankings(request: Request) throws -> Future<Response> {
        let eventFuture = try request.parameters.next(Event.self)
        let eventAndUserFuture = eventFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return eventAndUserFuture.flatMap { (event, user) in
            guard event.isVisible(to: user) else {
                throw Abort(.unauthorized)
            }
        
            let leaf = try request.make(LeafRenderer.self)
            let completedEventFuture = request.eventLoop.newSucceededFuture(result: event)
            
            // Scores hidden in competition mode
            if event.scoresHiddenBeforeEnd > 0, let endsAt = event.endsAt {
                let minutesRemaining = Int(endsAt.timeIntervalSinceNow / 60.0)
                if minutesRemaining >= 0, minutesRemaining < event.scoresHiddenBeforeEnd {
                    let context = RankingsViewContext(common: nil, event: completedEventFuture, rankings: request.eventLoop.newSucceededFuture(result: []))
                    return try leaf.render("Events/scores-hidden", context, request: request).encode(for: request)
                }
            }
        
            var sql = """
                SELECT
                    x.userID,
                    u.name userName,
                    u.email userEmail,
                    u.username userUsername,
                    u.role userRole,
                    u.hasImage userHasImage,
                    SUM(x.score) score,
                    SUM(x.passed) totalPassed,
                    SUM(x.elapsedTimeMinutes) totalTimeMinutes,
                    SUM(x.attempts) attempts,
                    MAX(x.lastSolvedAt) lastSolvedAt,
                    MAX(x.lastAttemptAt) lastAttemptAt,
                    COUNT(1) problems
                FROM users u
                JOIN (
                    SELECT
                        ss.userID,
                        ss.eventProblemID,
                        MAX(ss.score) score,
                        MAX(CASE WHEN ss.score = 100 THEN 1 ELSE 0 END) passed,
                        MIN(CASE WHEN ss.score = 100 THEN TIMESTAMPDIFF(MINUTE,IFNULL(e.startsAt,NOW()), ss.createdAt) ELSE NULL END) elapsedTimeMinutes,
                        COUNT(1) attempts,
                        MIN(CASE WHEN ss.score = 100 THEN ss.createdAt ELSE NULL END) lastSolvedAt,
                        MAX(ss.createdAt) lastAttemptAt
                    FROM submissions ss
                    JOIN event_problems ep ON ss.eventProblemID = ep.id
                    JOIN events e ON ep.eventID = e.id
                    WHERE ep.eventID = ? AND (ss.createdAt > e.startsAt OR e.startsAt IS NULL) AND
                        (ss.createdAt < e.endsAt OR e.endsAt IS NULL) AND
                        (ss.language = e.languageRestriction OR e.languageRestriction IS NULL)
                    GROUP BY userID, eventProblemID) x ON u.id = x.userID
                WHERE u.role = 1
                GROUP BY x.userID, u.name
            """
            
            switch event.scoringSystem {
            case .pointsThenLastCorrectSubmission:
                sql += " ORDER BY score DESC, lastSolvedAt ASC"
            case .pointsThenTotalTime:
                sql += " ORDER BY totalPassed DESC, totalTimeMinutes ASC"
            }
        
            let result = request.withPooledConnection(to: .mysql) { conn in
                return conn.query(sql, [event.id!])
            }
            let rankingsFuture = result.map { rows in
                return try rows.map { try PublicRanking(row: $0) }
            }

            let context = RankingsViewContext(common: nil, event: completedEventFuture, rankings: rankingsFuture)
            return try leaf.render("Events/scores", context, request: request).encode(for: request)
        }
    }
}

fileprivate struct IndexViewContext: ViewContext {
    var common: Future<CommonViewContext>?
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
    var common: Future<CommonViewContext>?
    let event: Future<Event>
    let problems: Future<[PublicEventProblem]>
}

fileprivate struct ProblemsViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let event: Future<Event>
    let problems: Future<[UserEventProblem]>
}

fileprivate struct SubmissionsViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let event: Future<Event>
    let submissions: Future<[PublicSubmission]>
}
    
fileprivate struct RankingsViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let event: Future<Event>
    let rankings: Future<[PublicRanking]>
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

extension PublicRanking {
    init(row: [MySQLColumn: MySQLData]) throws {
        let userID = try row.firstValue(forColumn: "userID")!.decode(Int.self)
        let userName = try row.firstValue(forColumn: "userName")!.decode(String.self)
        let userEmail = try row.firstValue(forColumn: "userEmail")!.decode(String.self)
        let userUsername = try row.firstValue(forColumn: "userUsername")!.decode(String.self)
        let userRole = try row.firstValue(forColumn: "userRole")!.decode(Int.self)
        let userHasImage = try row.firstValue(forColumn: "userHasImage")!.decode(Bool.self)
        let score = try row.firstValue(forColumn: "score")!.decode(Int.self)
        let totalPassed = try row.firstValue(forColumn: "totalPassed")!.decode(Int.self)
        let totalTimeMinutes = try row.firstValue(forColumn: "totalTimeMinutes")!.decode(Int.self)
        let attempts = try row.firstValue(forColumn: "attempts")!.decode(Int.self)
        let lastSolvedAt = try row.firstValue(forColumn: "lastSolvedAt")!.decode(Date.self)
        let lastAttemptAt = try row.firstValue(forColumn: "lastAttemptAt")!.decode(Date.self)
        let problems = try row.firstValue(forColumn: "problems")!.decode(Int.self)
        let user = PublicUser(id: userID, name: userName, email: userEmail, username: userUsername, role: Role(rawValue: userRole)!, lastLogin: nil, hasImage: userHasImage, color: PublicUser.colorFor(name: userName))
        self.init(user: user, score: score, totalPassed: totalPassed, totalTimeMinutes: totalTimeMinutes, attempts: attempts, lastSolvedAt: lastSolvedAt, lastAttemptAt: lastAttemptAt, problems: problems)
    }
}
