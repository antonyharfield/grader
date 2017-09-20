import Vapor
import HTTP
import Reswifq

final class ProblemsController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /events/:id/problems
    func problems(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        
        guard let user = request.user, event.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        let sql: String = [
            "SELECT p.*, ep.sequence, IFNULL(s.score,0) score, IFNULL(s.attempts,0) attempts",
            "FROM event_problems ep",
            "JOIN problems p ON ep.problem_id = p.id",
            "LEFT JOIN (",
                "SELECT s.user_id, s.event_problem_id, MAX(s.score) score, COUNT(1) attempts",
                "FROM submissions s",
                "GROUP BY user_id, event_problem_id) s ON ep.id = s.event_problem_id AND s.user_id = ?",
            "WHERE ep.event_id = ?",
            "ORDER BY ep.sequence"
            ].joined(separator: " ")
        
        let problems = try Problem.database!.raw(sql, [user.id!, event.id!])
        
        return try render("Events/event", [
            "event": event,
            "problems": problems
            ], for: request, with: view)
    }
    
    /// GET /events/:id/submissions
    func submissions(request: Request) throws -> ResponseRepresentable {
        
        let event = try request.parameters.next(Event.self)
        
        guard let user = request.user, event.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        var query = try Submission.makeQuery()
            .join(EventProblem.self, baseKey: "event_problem_id", joinedKey: "id")
            .filter(EventProblem.self, "event_id", event.id).sort("created_at", .descending).limit(20)
        
        if user.role == .student {
            query = try query.filter(Submission.self, "user_id", request.user!.id)
        }
        
        let submissions = try query.all()
        
        var shouldRefreshPageAutomatically = false
        
        var joinedSubmissions: [Node] = []
        for submission in submissions {
            var joinedSubmission = try submission.makeNode(in: nil)
            let user = try submission.user.get()!
            let problem = try submission.eventProblem.get()!.problem.get()!
            joinedSubmission["userName"] = user.name.makeNode(in: nil)
            joinedSubmission["problemName"] = problem.name.makeNode(in: nil)
            joinedSubmissions.append(joinedSubmission)
            
            if submission.state == .submitted || submission.state == .gradingInProgress {
                shouldRefreshPageAutomatically = true
            }
        }
        
        return try render("Events/submissions", [
            "event": event,
            "submissions": joinedSubmissions,
            "shouldRefresh": shouldRefreshPageAutomatically
            ], for: request, with: view)
    }
    
    /// GET /events/:id/scores
    func scores(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        
        guard let user = request.user, event.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        let scores = try User.database!.raw("SELECT x.user_id, u.name, SUM(x.score) score, SUM(x.attempts) attempts, COUNT(1) problems FROM users u JOIN (SELECT s.user_id, s.event_problem_id, MAX(s.score) score, COUNT(1) attempts FROM submissions s JOIN event_problems ep ON s.event_problem_id = ep.id JOIN events e ON ep.event_id = e.id WHERE ep.event_id = ? AND (s.created_at > e.starts_at OR e.starts_at is null) AND (s.created_at < e.ends_at OR e.ends_at is null) GROUP BY user_id, event_problem_id) x ON u.id = x.user_id WHERE u.role = 1 GROUP BY x.user_id, u.name ORDER BY score DESC, attempts ASC, problems DESC", [event.id!])
        
        return try render("Events/scores", [
            "event": event,
            "scores": scores
            ], for: request, with: view)
    }
    
    /// GET /events/:id/problems/:seq
    func form(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let sequence = try request.parameters.next(Int.self)
        
        guard let user = request.user, event.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        guard let eventProblem = try event.eventProblems.filter("sequence", sequence).first(),
            let problem = try eventProblem.problem.get() else {
                throw Abort.notFound
        }
        
        let problemCases = try problem.cases.filter("visible", true).all()
        
        return try render("Events/problem-form", [
            "event": event,
            "eventProblem": eventProblem,
            "problem": problem,
            "problemCases": problemCases
            ], for: request, with: view)
    }
    
    /// POST /events/:id/problems/:seq
    func submit(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let sequence = try request.parameters.next(Int.self)
        
        guard let user = request.user, event.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        guard let eventProblem = try event.eventProblems.filter("sequence", sequence).first() else {
            throw Abort.notFound
        }
        
        let languageEither = event.languageRestriction
            ?? request.data["language"]?.string.flatMap { raw in Language(rawValue: raw) }
        
        guard let fileData = request.formData?["file"],
            let filename = fileData.filename, let bytes = fileData.bytes,
            let mimeType = fileData.part.headers["Content-Type"],
            let language = languageEither
        else {
            throw Abort.badRequest
        }
        
        // TODO: support multiple file uploads
        let files: [(String, [UInt8])] = [(filename, bytes)]
        
        // Create submission first so it has an ID
        let submission = Submission(eventProblemID: eventProblem.id!, userID: user.id!, language: language, files: files.map { $0.0 })
        try submission.save()
        
        // Save the files
        let fileSystem = FileSystem()
        let uploadPath = fileSystem.submissionUploadPath(submission: submission)
        fileSystem.ensurePathExists(path: uploadPath)
        for file in files {
            if !fileSystem.save(bytes: file.1, path: uploadPath + file.0) {
                throw Abort.badRequest
            }
        }
        
        // Queue job
        // TODO: don't fail if we cannot connect to the queue!
        let job = SubmissionJob(submissionID: submission.id!.int!)
        try Reswifq.defaultQueue.enqueue(job)
        
        return Response(redirect: "/events/\(event.id!.string!)/submissions")
    }
    
    /// GET /problems/:id/cases/new
    func problemCaseNew(request: Request) throws -> ResponseRepresentable {
        return try render("Events/Teacher/problem-case-new", for: request, with: view)
    }
    
    /// POST /problems/:id/cases/new
    func problemCaseNewSubmit(request: Request) throws -> ResponseRepresentable {
        
        let problem = try request.parameters.next(Problem.self)
        
        guard
            let problemId = problem.id,
            let visibility = request.data["visibility"]?.string
        else {
            throw Abort.badRequest
        }
        
        let visible = (visibility == "display")
        let caseInput = request.data["case_input"]?.string ?? ""
        let caseOutput = request.data["case_output"]?.string ?? ""
        
        // Save & continue
        let problemCase = ProblemCase(input: caseInput, output: caseOutput, visible: visible, problemID: problemId)
        try problemCase.save()
        
        return Response(redirect: "/problems/\(problemId.string!)/cases/new")
    }

}
