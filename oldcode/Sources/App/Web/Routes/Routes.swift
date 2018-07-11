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
        
        let userController = UsersController(view)
        builder.get("users", User.parameter, "image", handler: userController.image)
        
        let eventsController = EventsController(view)
        builder.resource("events", eventsController)
        builder.get("events", Event.parameter, "image", handler: eventsController.image)
        
        let rankingsController = RankingsController(view)
        builder.get("rankings", handler: rankingsController.global)
    }
}
