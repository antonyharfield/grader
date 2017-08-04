import HTTP
import Vapor
import AuthProvider

final class GuardMiddleware<U: Authenticatable>: Middleware {
    
    public init(_ userType: U.Type = U.self) {}

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard request.auth.isAuthenticated(U.self) else {
            return Response(redirect: "/login")
        }
        return try next.respond(to: request)
    }
}

final class InverseGuardMiddleware<U: Authenticatable>: Middleware {
    
    public init(_ userType: U.Type = U.self) {}
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard !request.auth.isAuthenticated(U.self) else {
            return Response(redirect: "/")
        }

        return try next.respond(to: request)
    }
}
