import Vapor
import HTTP
import AuthProvider
import Flash

final class LoginController {
    
    let homepage = "/events"
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// Landing
    ///
    /// - Parameter request: Request
    /// - Returns: Response
    public func landing(request: Request) -> Response {
        if request.auth.isAuthenticated(User.self) {
            return Response(redirect: homepage)
        }
        else {
            return Response(redirect: "/login")
        }
    }
    
    /// Login page
    public func loginForm(request: Request) throws -> ResponseRepresentable {
        return try render("Auth/login", for: request, with: view)
    }

    /// Login page submission
    func login(_ request: Request) throws -> ResponseRepresentable {
        
        guard let email = request.data["email"]?.string,
            let password = request.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let credentials = Password(username: email, password: password)
        do {
            let user = try User.authenticate(credentials)
            try request.auth.authenticate(user, persist: true)
            return Response(redirect: homepage)
        } catch {
            return Response(redirect: "/login").flash(.error, "Wrong email or password.")
        }
    }
    
    /// Register page
    public func registerForm(request: Request) throws -> ResponseRepresentable {
        return try render("Auth/register", for: request, with: view)
    }

    /// Register page submission
    func register(_ request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string,
            let password = request.data["password"]?.string,
            let name = request.data["name"]?.string else {
                throw Abort.badRequest
        }
        
        let user = User(name: name, username: email, password: password, role: .student)
        try user.save()
        
        let credentials = Password(username: email, password: password)
        do {
            let user = try User.authenticate(credentials)
            try request.auth.authenticate(user, persist: true)
            return Response(redirect: homepage)
        } catch {
            return Response(redirect: "/register").flash(.error, "Something bad happened.")
        }

    }
    
}
