import Vapor
import Flash
import Leaf
import Crypto

extension LoginController: RouteCollection {
    func boot(router: Router) throws {
        router.post("register", use: register)
        router.get("register", use: registerForm)
        
        router.post("login", use: login)
        router.get("login", use: loginForm)
    }
}

final class LoginController {

    public static let homepageRoute = "/"
    public static let loginRoute = "/login"
    

    /// Login page
    func loginForm(_ request: Request) throws -> Future<View> {
        let leaf = try request.privateContainer.make(LeafRenderer.self)
        return leaf.render("Auth/login", request: request)
    }

    /// Login page submission
    func login(_ request: Request) throws -> Future<Response> {
        let redirectPath = request.query[String.self, at: "next"] ?? LoginController.homepageRoute
        return try request.content.decode(UserLogin.self).flatMap(to: Response.self) { user in
            let verifier = try request.make(BCryptDigest.self)
            return User.authenticate(username: user.username, password: user.password, using: verifier, on: request)
                .unwrap(or: Abort(.unauthorized))
                .map(to: Response.self, { authedUser  in
                    
                    try request.sessionAuthenticate(user: authedUser)

                    authedUser.lastLogin = Date()
                    _ = authedUser.save(on: request)
                    
                    return request.redirect(to: redirectPath)
                })
            }.catchFlatMap({ error in
                if let error = error as? HTTPResponseStatus, case HTTPResponseStatus.unauthorized = error {
                    return request.future(request.redirect(to: LoginController.loginRoute).flash(.error, "Incorrect username or password"))
                }
                return request.future(request.redirect(to: LoginController.loginRoute).flash(.error, "Unknown error"))
            })
    }
    
    /// Register page
    func registerForm(_ request: Request) throws -> Future<View> {
        let leaf = try request.privateContainer.make(LeafRenderer.self)
        return leaf.render("Auth/register", request: request)
    }

    /// Register page submission
    func register(_ request: Request) throws -> Future<Response> {
        return try request.content.decode(UserRegistration.self).flatMap { userRegistration -> EventLoopFuture<User> in
                let verifier = try request.make(BCryptDigest.self)
                let user = userRegistration.toUser()
                user.password = try verifier.hash(user.password)
                return user.save(on: request)
            }.flatMap { user in
                try request.session()["userId"] = "\(try user.requireID())"
                return request.future(request.redirect(to: "/"))
            }
    }

}

fileprivate struct UserLogin: Content {
    var username: String
    var password: String
}

fileprivate struct UserRegistration: Content {
    var email: String
    var username: String
    var password: String
    var name: String
    
    func toUser() -> User {
        let user = User(name: name, email: email, username: username, password: password, role: .student)
        user.lastLogin = Date()
        return user
    }
}
