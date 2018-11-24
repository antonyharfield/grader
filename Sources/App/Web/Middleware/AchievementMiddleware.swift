import Vapor
import FluentMySQL

final class AchievementMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        return try request.requireSessionUser().flatMap { user in
            return try user.achievementsRaw.query(on: request).filter(\AchievementUser.hasSeen == false).first()
        }.flatMap { achievement in
            if let achievement = achievement {
                return request.future(request.redirect(to: "/achievements/\(achievement.id!)"))
            }
            return try next.respond(to: request)
        }
    }
    
}
