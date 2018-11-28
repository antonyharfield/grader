import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: ManageCoursesController())
    try router.register(collection: APIController())
    try router.register(collection: EventsController())
    try router.register(collection: CoursesController())
    try router.register(collection: ProblemController())
    try router.register(collection: StaticContentController())
    try router.register(collection: RankingsController())
    try router.register(collection: LoginController())
    try router.register(collection: ProfileController())
    try router.register(collection: AchievementsController())
}
