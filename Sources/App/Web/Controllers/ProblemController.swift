import Vapor
//import Reswifq
import Leaf
import FluentMySQL

extension ProblemController: RouteCollection {
    func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("events", Event.parameter, "problems", Int.parameter, use: form)
        authedRouter.post("events", Event.parameter, "problems", Int.parameter, use: submit)
    }
}

final class ProblemController {

    func form(request: Request) throws -> Future<View> {
        let eventFuture = try request.parameters.next(Event.self)
        let sequence = try request.parameters.next(Int.self)

        let eventAndUserFuture = eventFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return eventAndUserFuture.flatMap { (event, user) in
            guard event.isVisible(to: user) else {
                throw Abort(.unauthorized)
            }
            
            let eventProblemFuture = try event.eventProblems.query(on: request).filter(\.sequence == sequence).first().unwrap(or: Abort(.notFound))
            return eventProblemFuture.flatMap { eventProblem in
                let problem = eventProblem.problem.get(on: request)
                let problemCases = ProblemCase.query(on: request).filter(\.problemID == eventProblem.problemID).filter(\.visibility == ProblemCaseVisibility.show).all()
                
                let context = ProblemViewContext(common: nil, event: event, eventProblem: eventProblem, problem: problem, problemCases: problemCases)
                let leaf = try request.make(LeafRenderer.self)
                return leaf.render("Events/problem-form", context, request: request)
            }
        }
    }

    func submit(request: Request) throws -> Future<Response> {
        let submissionData = try request.content.decode(SubmissionData.self)
        let eventProblemFuture = try process(request: request)
        
        return submissionData.and(eventProblemFuture).flatMap { submissionData, ueep in
            let user = ueep.user
            let event = ueep.event
            let eventProblem = ueep.eventProblem
            
            guard let language = event.languageRestriction
                ?? Language(rawValue: submissionData.language) else {
                throw Abort(.badRequest)
            }
            let filename = submissionData.file.filename
            let fileData = submissionData.file.data
            
            // Create submission first so it has an ID
            let submission = Submission(eventProblemID: eventProblem.id!, userID: user.id!, language: language, files: filename)
            return submission.save(on: request).flatMap { submission in
                
                // Save the files
                let fileSystem = FileSystem()
                let uploadPath = fileSystem.submissionUploadPath(submission: submission)
                fileSystem.ensurePathExists(at: uploadPath)
                fileSystem.save(data: fileData, path: uploadPath + filename)
                
                // Queue job
                // TODO: don't fail if we cannot connect to the queue!
                let job = SubmissionJob(submissionID: submission.id!.int!)
                try Reswifq.defaultQueue.enqueue(job)
            }
            
            return request.redirect(to: "/events/\(event.id!)/submissions")
        }
    }
    
    private func process(request: Request) throws -> Future<UserEventProblem> {
        let eventFuture = try request.parameters.next(Event.self)
        let sequence = try request.parameters.next(Int.self)
        
        let eventAndUserFuture = eventFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return eventAndUserFuture.flatMap { (event, user) in
            guard event.isVisible(to: user) else {
                throw Abort(.unauthorized)
            }
            
            let eventProblemFuture = try event.eventProblems.query(on: request).filter(\.sequence == sequence).first().unwrap(or: Abort(.notFound))
            return eventProblemFuture.flatMap { eventProblem in
                return request.future(UserEventProblem(user: user, event: event, eventProblem: eventProblem))
            }
        }
    }

}

fileprivate struct ProblemViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let event: Event
    let eventProblem: EventProblem
    let problem: Future<Problem>
    let problemCases: Future<[ProblemCase]>
}

fileprivate struct UserEventProblem {
    let user: User
    let event: Event
    let eventProblem: EventProblem
}
