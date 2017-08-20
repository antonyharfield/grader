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
        
        guard let eventProblem = try event.eventProblems.filter("sequence", sequence).first(),
            let problem = try eventProblem.problem.get() else {
                throw Abort.notFound
        }
        
        let problemCases = try problem.cases.filter("visible", true).all()
        
        return try render("problem-form", [
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
        
        guard let eventProblem = try event.eventProblems.filter("sequence", sequence).first(),
            let problem = try eventProblem.problem.get(), let user = request.user else {
                throw Abort.notFound
        }
        
        guard let fileData = request.formData?["file"],
            let filename = fileData.filename, let bytes = fileData.bytes,
            let mimeType = fileData.part.headers["Content-Type"] else {
            throw Abort.badRequest
        }
        
        // TODO: support multiple file uploads
        let files: [(String, [UInt8])] = [(filename, bytes)]
        
        // Create submission first so it has an ID
        let submission = Submission(eventProblemID: eventProblem.id!, userID: user.id!, files: files.map { $0.0 })
        try submission.save()
        
        // Save the files
        let fileSystem = FileSystem()
        let uploadPath = fileSystem.uploadPath(submission: submission)
        fileSystem.ensurePathExists(path: uploadPath)
        for file in files {
            if !fileSystem.save(bytes: file.1, path: uploadPath + file.0) {
                throw Abort.badRequest
            }
        }
        
        // Queue job
        let job = SubmissionJob(submissionID: submission.id!)
        try Reswifq.defaultQueue.enqueue(job)
        
        return Response(redirect: "/events/\(event.id!.string!)/submissions")
    }

}
