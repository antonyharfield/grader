import Vapor
import Leaf
import FluentMySQL

extension AchievementsController: RouteCollection {
    func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("achievements", AchievementUser.parameter, use: show)
    }
}

final class AchievementsController {
    
    func show(request: Request) throws -> Future<View> {
        return try request.parameters.next(AchievementUser.self).flatMap { achievementUser in
            if achievementUser.userID != request.cachedSessionUser()?.id {
                throw Abort(.notFound)
            }
            
            let leaf = try request.make(LeafRenderer.self)
            let context = AchievementViewContext(common: nil, acheivementUser: achievementUser, acheivement: achievementUser.achievement.get(on: request))
            return leaf.render("Achievements/show", context, request: request)
        }
    }

}

fileprivate struct AchievementViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let acheivementUser: AchievementUser
    let acheivement: Future<Achievement>
}
