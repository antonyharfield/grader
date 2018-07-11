import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("/", use: PublicController().home)
    
    try router.register(collection: StaticContentController())
    try router.register(collection: RankingsController())
    try router.register(collection: LoginController())
    try router.register(collection: ProfileController())
}
