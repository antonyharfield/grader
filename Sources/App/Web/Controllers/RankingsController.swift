import Vapor
import HTTP

final class RankingsController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /rankings
    func global(request: Request) throws -> ResponseRepresentable {
        
        let scores = try User.database!.raw("""
            SELECT
                x.user_id userID,
                u.name userName,
                u.has_image userHasImage,
                SUM(x.score) score,
                SUM(x.elapsed_time_minutes) totalTimeMinutes,
                SUM(x.attempts) attempts,
                MAX(x.last_attempt_at) lastAttemptAt,
                COUNT(1) problems
            FROM users u
            JOIN (
                SELECT
                    ss.user_id,
                    ss.event_problem_id,
                    MAX(ss.score) score,
                    MIN(CASE WHEN ss.score = 100 THEN TIMESTAMPDIFF(MINUTE,IFNULL(e.starts_at,NOW()), ss.created_at) ELSE NULL END) elapsed_time_minutes,
                    COUNT(1) attempts,
                    MAX(ss.created_at) last_attempt_at
                FROM submissions ss
                JOIN event_problems ep ON ss.event_problem_id = ep.id
                JOIN events e ON ep.event_id = e.id
                WHERE (ss.created_at > e.starts_at OR e.starts_at IS NULL) AND
                    (ss.created_at < e.ends_at OR e.ends_at IS NULL) AND
                    (ss.language = e.language_restriction OR e.language_restriction IS NULL)
                GROUP BY user_id, event_problem_id) x ON u.id = x.user_id
            WHERE u.role = 1
            GROUP BY x.user_id, u.name
            ORDER BY score DESC, totalTimeMinutes ASC
            LIMIT 25
        """)
        
        let colorHash = PFColorHash()
        var joinedScores = [Node]()
        for score in scores.array! {
            var joinedScore = score
            joinedScore["userColor"] = colorHash.hex(score["userName"]!.string!).makeNode(in: nil)
            joinedScores.append(joinedScore)
        }
        
        return try render("rankings", [
            "scores": joinedScores
            ], for: request, with: view)
    }
}
