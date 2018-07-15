import Vapor
import HTTP
import Reswifq

final class ProblemsController {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
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

        let problemCases = try problem.cases.filter("visibility", ProblemCaseVisibility.show.rawValue).all()

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

}
