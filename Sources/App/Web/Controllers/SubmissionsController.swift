import Vapor
import HTTP
import Reswifq

final class SubmissionsController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }

    func manualRun(request: Request) throws -> ResponseRepresentable {
        
        let submission = try request.parameters.next(Submission.self)
        
        let job = SubmissionJob(submissionID: submission.id!.int!)
        try Reswifq.defaultQueue.enqueue(job)
        
        let eventProblem = try submission.eventProblem.get()

        return Response(redirect: "/events/\(eventProblem!.eventID.string!)/submissions")
    }
}
