import Vapor

final class GuardPermissionsMiddleware: Middleware {
    
    let permissions: [Permission]
    
    init(_ permissions: Permission...) {
        self.permissions = permissions
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        return request.sessionUser().flatMap { user in
            // User must have ALL required permissions
            guard let user = user, user.can(self.permissions) else {
                throw Abort.init(HTTPResponseStatus.unauthorized)
            }
            return try next.respond(to: request)
        }
        
    }
    
}
