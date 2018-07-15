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
        return sessionUser().unwrap(or: Abort(HTTPResponseStatus.internalServerError))
    }
    
    func sessionUser() -> Future<User?> {
        if let sess = try? session(), let idRaw = sess[SessionKeys.userID], let id = Int(idRaw)   {
            return User.find(id, on: self)
        }
        return eventLoop.newSucceededFuture(result: nil)
    }
    
    func cachedSessionUser() -> User? {
        guard let session = try? self.session() else {
            return nil
        }
        guard let id = Int(session[SessionKeys.userID] ?? ""),
            let name = session[SessionKeys.userName],
            let email = session[SessionKeys.userEmail],
            let username = session[SessionKeys.userUsername],
            let role = Role(rawValue: Int(session[SessionKeys.userRole] ?? "") ?? 0),
            let lastLogin = TimeInterval(session[SessionKeys.userLastLogin] ?? "").map({ Date(timeIntervalSince1970: $0) }),
            let hasImage = session[SessionKeys.userHasImage].flatMap({ Bool($0) }) else {
                return nil
        }
        return User(id: id, name: name, email: email, username: username, password: "", role: role, lastLogin: lastLogin, hasImage: hasImage)
    }
    
    func sessionIsAuthenticated() throws -> Bool {
        return try self.session()[SessionKeys.userID] != nil
    }
    
    func sessionAuthenticate(user: User) throws {
        let session = try self.session()
        session[SessionKeys.userID] = "\(try user.requireID())"
        session[SessionKeys.userName] = user.name
        session[SessionKeys.userEmail] = user.email
        session[SessionKeys.userUsername] = user.username
        session[SessionKeys.userRole] = String(user.role.rawValue)
        session[SessionKeys.userLastLogin] = String(user.lastLogin?.timeIntervalSince1970 ?? 0)
        session[SessionKeys.userHasImage] = "\(user.hasImage)"
    }
    
    func sessionLogout() throws {
        try self.destroySession()
    }
}
