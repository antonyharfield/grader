import Vapor
import FluentMySQL

extension APIController: RouteCollection {
    func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("api", "submissions", use: getSubmissions)
        authedRouter.get("api", "problems", use: getProblems)
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
    
    func getProblems(request: Request) throws -> Future<ProblemsResponse> {
        let keywordRaw = request.query[String.self, at: "keyword"]
        
        guard let keyword = keywordRaw, keyword.count > 2 else {
            return request.future(ProblemsResponse(problems: []))
        }
        
        let sql: String = [
            "SELECT id, name, description FROM problems",
            "WHERE name like ?",
            "ORDER BY id DESC"
            ].joined(separator: " ")
        let params = ["%\(keyword)%"]
        
        let problemsFuture: Future<[[MySQLColumn: MySQLData]]> = request.withPooledConnection(to: .mysql) { (conn: MySQLDatabase.Connection) in
            return conn.raw(sql).binds(params).all()
        }
        
        return problemsFuture.map(parseProblems).flatMap { problems in
            return request.future(ProblemsResponse(problems: problems))
        }
    }
    
    private func parseProblems(rows: [[MySQLColumn: MySQLData]]) throws -> [PublicProblem] {
        var results: [PublicProblem] = []
        for row in rows {
            let id = try row.firstValue(forColumn: "id")!.decode(Int.self)
            let name = try row.firstValue(forColumn: "name")!.decode(String.self)
            let description = try row.firstValue(forColumn: "description")!.decode(String.self)
            results.append(PublicProblem(id: id, name: name, description: description))
        }
        return results
    }
}

struct SubmissionsRequest: Content {
    var eventProblemID: Int?
    var topicItemID: Int?
}
struct SubmissionsResponse: Content {
    let submissions: [Submission]
}

struct ProblemsResponse: Content {
    let problems: [PublicProblem]
}
