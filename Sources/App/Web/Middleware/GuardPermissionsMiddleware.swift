import HTTP
import Vapor
import AuthProvider

final class GuardPermissionsMiddleware: Middleware {
    
    let permissions: [Permission]
    
    init(_ permissions: Permission...) {
        self.permissions = permissions
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        // User must have ALL required permissions
        guard let user: User = request.user, user.can(permissions)
        else { throw Abort.unauthorized }
        
        return try next.respond(to: request)
    }
    
}
