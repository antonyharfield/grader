import Vapor
import VaporRedisClient
import Redis
import Reswifq

final class Routes: RouteCollection {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        /// GET /
        builder.get { req in
            if req.auth.isAuthenticated(User.self) {
                return Response(redirect: "/events")
            }
            return Response(redirect: "/login")
        }
        
        let loginController = LoginController(view)
        builder.get("login", handler: loginController.loginForm)
        builder.post("login", handler: loginController.login)
        builder.get("register", handler: loginController.registerForm)
        builder.post("register", handler: loginController.register)
        
        builder.resource("events", EventsController(view))
    }
}
