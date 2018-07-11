import Vapor
import Leaf
import FluentMySQL

public final class PublicController {
    
    func home(_ request: Request) throws -> Future<View> {
        
        let activeEvents = Event.query(on: request).filter(\.status == .published).sort(\Event.id, .descending).all()
        //.filter(raw: "status = 2 AND (starts_at is null OR starts_at < CURRENT_TIMESTAMP) AND (ends_at is null OR ends_at > CURRENT_TIMESTAMP)")
        
        let pastEvents = Event.query(on: request).filter("status = 2 AND ends_at < CURRENT_TIMESTAMP").sort(\Event.id, .descending).all()

        let leaf = try request.make(LeafRenderer.self)
        let context = HomeViewContext(activeEvents: activeEvents, pastEvents: pastEvents)
        return leaf.render("Events/events", context, request: request)
    }
}

fileprivate struct HomeViewContext: ViewContext {
    var common: CommonViewContext?
    let activeEvents: Future<[Event]>
    let pastEvents: Future<[Event]>
    init(activeEvents: Future<[Event]>, pastEvents: Future<[Event]>) {
        self.activeEvents = activeEvents
        self.pastEvents = pastEvents
    }
}
