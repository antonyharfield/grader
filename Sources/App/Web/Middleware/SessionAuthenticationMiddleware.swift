import Vapor

final class SessionAuthenticationMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let session = try request.session()
        if let _ = session[SessionKeys.userID] {
            return try next.respond(to: request)
        }
        //throw Abort(HTTPResponseStatus.unauthorized)
        let redirect = request.redirect(to: LoginController.loginRoute)
        return request.eventLoop.newSucceededFuture(result: redirect)
    }
}

extension Request {
    func requireSessionUser() throws -> Future<User> {
        return sessionUser().unwrap(or: Abort(HTTPResponseStatus.notFound))
    }
    
    func sessionUser() -> Future<User?> {
        if let sess = try? session(), let userId = sess[SessionKeys.userID], let idAsInt = Int(userId)   {
            return User.find(idAsInt, on: self)
        }
        return eventLoop.newSucceededFuture(result: nil)
    }
    
    func sessionIsAuthenticated() throws -> Bool {
        return try self.session()[SessionKeys.userID] != nil
    }
    
    func sessionAuthenticate(user: User) throws {
        let session = try self.session()
        session[SessionKeys.userID] = "\(try user.requireID())"
    }
    
    func sessionLogout() throws {
        try self.session()[SessionKeys.userID] = nil
    }
}
