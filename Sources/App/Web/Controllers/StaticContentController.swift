import Vapor
import Leaf

extension StaticContentController: RouteCollection {
    func boot(router: Router) throws {
        router.get("about", use: about)
    }
}

final class StaticContentController {
    
    /// Returns the about page
    func about(_ request: Request) throws -> Future<View> {
        let leaf = try request.make(LeafRenderer.self)
        return leaf.render("about", request: request)
    }
}
