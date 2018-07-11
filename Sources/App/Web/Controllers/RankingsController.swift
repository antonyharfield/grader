import Vapor
import Leaf
import FluentMySQL

extension RankingsController: RouteCollection {
    func boot(router: Router) throws {
        router.get("rankings", use: global)
    }
}

final class RankingsController {
    
    /// GET /rankings
    func global(_ request: Request) throws -> Future<View> {
        
        let sql = """
            SELECT
                x.userID userID,
                u.name userName,
                u.hasImage userHasImage,
                SUM(x.score) score,
                SUM(x.elapsedTimeMinutes) totalTimeMinutes,
                SUM(x.attempts) attempts,
                MAX(x.lastAttemptAt) lastAttemptAt,
                COUNT(1) problems
            FROM users u
            JOIN (
                SELECT
                    ss.userID,
                    ss.eventProblemID,
                    MAX(ss.score) score,
                    MIN(CASE WHEN ss.score = 100 THEN TIMESTAMPDIFF(MINUTE,IFNULL(e.startsAt,NOW()), ss.createdAt) ELSE NULL END) elapsedTimeMinutes,
                    COUNT(1) attempts,
                    MAX(ss.createdAt) lastAttemptAt
                FROM submissions ss
                JOIN event_problems ep ON ss.eventProblemID = ep.id
                JOIN events e ON ep.eventID = e.id
                WHERE (ss.createdAt > e.startsAt OR e.startsAt IS NULL) AND
                    (ss.createdAt < e.endsAt OR e.endsAt IS NULL) AND
                    (ss.language = e.languageRestriction OR e.languageRestriction IS NULL)
                GROUP BY userID, eventProblemID) x ON u.id = x.userID
            WHERE u.role = 1
            GROUP BY x.userID, u.name
            ORDER BY score DESC, totalTimeMinutes ASC
            LIMIT 25
        """
        
        let rows = request.withPooledConnection(to: .mysql) { conn in
            return conn.simpleQuery(sql)
        }
        
        return rows.map(parse).flatMap { rankings in
            let leaf = try request.make(LeafRenderer.self)
            return leaf.render("rankings", RankingsViewContext(rankings: rankings), request: request)
        }
    }
    
    private func parse(rows: [[MySQLColumn: MySQLData]]) throws -> [Ranking] {
        let colorHash = PFColorHash()
        
        var rankings: [Ranking] = []
        for row in rows {
            let userID = try row.firstValue(forColumn: "userID")!.decode(Int.self)
            let userName = try row.firstValue(forColumn: "userName")!.decode(String.self)
            let userHasImage = try row.firstValue(forColumn: "userHasImage")!.decode(Bool.self)
            let userColor = colorHash.hex(userName)
            let score = try row.firstValue(forColumn: "score")!.decode(Int.self)
            let totalTimeMinutes = try row.firstValue(forColumn: "totalTimeMinutes")!.decode(Int.self)
            let attempts = try row.firstValue(forColumn: "attempts")!.decode(Int.self)
            let lastAttemptAt = Date() //try row.firstValue(forColumn: "lastAttemptAt")!.decode(Date.self) // TODO: fix
            let problems = try row.firstValue(forColumn: "problems")!.decode(Int.self)
            let ranking = Ranking(userID: userID, userName: userName, userHasImage: userHasImage, userColor: userColor, score: score, totalTimeMinutes: totalTimeMinutes, attempts: attempts, lastAttemptAt: lastAttemptAt, problems: problems)
            rankings.append(ranking)
        }
        return rankings
    }
}

fileprivate struct Ranking: Encodable {
    let userID: Int
    let userName: String
    let userHasImage: Bool
    let userColor: String
    let score: Int
    let totalTimeMinutes: Int
    let attempts: Int
    let lastAttemptAt: Date
    let problems: Int
}

fileprivate struct RankingsViewContext: ViewContext {
    var common: CommonViewContext?
    let rankings: [Ranking]
    init(rankings: [Ranking]) {
        self.rankings = rankings
    }
}
