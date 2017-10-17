import Vapor
import HTTP

final class StaticContentController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /about
    func about(request: Request) throws -> ResponseRepresentable {
        return try render("about", for: request, with: view)
    }
}

