import Vapor
import HTTP

final class ProblemsController: ResourceRepresentable {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /problems
    func index(_ req: Request) throws -> ResponseRepresentable {
        // Query
        let problems = try Problem.all()
        
        return try view.make("problems", wrapUserData([
            "problems": problems
        ], for: req), for: req)
    }
    
    /// GET /problems/:id
    func show(_ req: Request, _ id: String) throws -> ResponseRepresentable {
        
        if let problem = try Problem.find(id) {
            return try view.make("problemdetail", wrapUserData([
                "problem": problem
            ], for: req), for: req)
        }
        
        throw Abort.notFound
    }

    func makeResource() -> Resource<String> {
        return Resource(index: index, show: show)
    }
}
