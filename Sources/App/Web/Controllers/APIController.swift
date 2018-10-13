import Vapor
import FluentMySQL

extension APIController: RouteCollection {
    func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("api", "submissions", use: getSubmissions)
    }
}

final class APIController {
    
    func getSubmissions(request: Request) throws -> Future<SubmissionsResponse> {
        let filters = try request.query.decode(SubmissionsRequest.self)
        let userFuture = try request.requireSessionUser()
        
        return userFuture.flatMap { user -> Future<[Submission]> in
            
            var submissions = Submission.query(on: request).sort(\.createdAt, .descending)
                .filter(\.userID == user.id!)
            
            if let topicItemID = filters.topicItemID {
                submissions = submissions.filter(\.topicItemID == topicItemID)
            }
            if let eventProblemID = filters.eventProblemID {
                submissions = submissions.filter(\.eventProblemID == eventProblemID)
            }
            return submissions.all()
        }.flatMap { submissions -> Future<SubmissionsResponse> in
            return request.future(SubmissionsResponse(submissions: submissions))
        }
    }
}

struct SubmissionsRequest: Content {
    var eventProblemID: Int?
    var topicItemID: Int?
}
struct SubmissionsResponse: Content {
    let submissions: [Submission]
}
