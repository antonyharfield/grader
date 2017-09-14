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
        
        let userController = UsersController(view)
        builder.get("users", handler: userController.showUser)
        builder.get("users", Int.parameter, "edit", handler: userController.editForm)
        builder.post("users", Int.parameter, "edit", handler: userController.edit)
        
        builder.get("users", Int.parameter,"delete", handler: userController.deleteForm)
        builder.post("users", Int.parameter,"delete", handler: userController.delete)
        
        builder.resource("events", EventsController(view))

        builder.get("about") { req in
            return try render("about", for: req, with: self.view)
        }
        
//        builder.get("job") { request in
//            let submission = try Submission.find(6)
//            print("got submission")
//            let job = SubmissionJob(submissionID: submission!.id!.int!)
//            print("got job")
//            try! Reswifq.defaultQueue.enqueue(job)
//            print("queued")
//            
//            try Reswifq.defaultQueue.enqueue(DemoJob())
//            return Response(status: .ok)
//        }
    }
}
