import HTTP
import Vapor
import AuthProvider

final class GuardRoleMiddleware: Middleware {
    
    let roles: [Role]
    
    init(roles: [Role]) {
        self.roles = roles
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let user = request.user, roles.contains(user.role) else {
            throw Abort.unauthorized
        }
        return try next.respond(to: request)
    }
}
