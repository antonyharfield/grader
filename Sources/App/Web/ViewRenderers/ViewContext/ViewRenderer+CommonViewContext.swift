import Foundation
import Vapor
import Leaf

extension ViewRenderer {
    
    func render<V>(_ path: String, _ context: V, request: Request) -> Future<View> where V: ViewContext {

        var finalContext = context
        finalContext.common = makeCommonViewContext(request: request)
        return self.render(path, finalContext)
    }
    
    func render(_ path: String, request: Request) -> Future<View> {
        let context = NoContextCommonViewContext(common: makeCommonViewContext(request: request))
        return self.render(path, context)
    }
    
    private func makeCommonViewContext(request: Request) -> Future<CommonViewContext> {
        let url = request.http.url
        
        return request.eventLoop.newSucceededFuture(result: CommonViewContext(user: request.cachedSessionUser(), url: url))
    }
}

struct NoContextCommonViewContext: ViewContext {
    var common: Future<CommonViewContext>?
}

struct ErrorViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    var error: String
    
    init(error: String) {
        self.error = error
    }
}
