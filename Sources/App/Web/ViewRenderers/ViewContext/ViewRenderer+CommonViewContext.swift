import Foundation
import Vapor
import Leaf

extension ViewRenderer {
    
    func render<V>(_ path: String, _ context: V, request: Request) -> Future<View> where V: ViewContext {
        
        return makeCommonViewContext(request: request).flatMap { commonViewContext in
            var finalContext = context
            finalContext.common = commonViewContext
            return self.render(path, finalContext)
        }
    }
    
    func render(_ path: String, request: Request) -> Future<View> {
        return makeCommonViewContext(request: request).flatMap { commonViewContext in
            let context = NoContextCommonViewContext(common: commonViewContext)
            return self.render(path, context)
        }
    }
    
    private func makeCommonViewContext(request: Request) -> Future<CommonViewContext> {
        let url = request.http.url
        
        return request.sessionUser().map { user in
            return CommonViewContext(user: user, url: url)
        }
    }
    
    
//    func render<V>(_ path: String, _ context: V, request: Request) throws -> Future<View> where V: ViewContext {
//        var commonViewContext = try request.make(CommonViewContext.self)
//        try finishCommonContext(request: request, cvc: &commonViewContext)
//
//        var finalContext = context
//        finalContext.common = commonViewContext
//
//        return render(path, finalContext)
//    }
//
//    func render(_ path: String, request: Request) throws -> Future<View> {
//        var commonViewContext = try request.make(CommonViewContext.self)
//        try finishCommonContext(request: request, cvc: &commonViewContext)
//
//        return render(path, NoContextCommonViewContext(common: commonViewContext))
//    }
//
//
//    private func finishCommonContext(request: Request, cvc: inout CommonViewContext) throws {
//        let session = try request.session()
//        var userId: Int?
//
//        if let userIdString = session[SessionKeys.userID] {
//            userId = Int(userIdString)
//        }
//
//        cvc.userObject = CommonViewContext.CommonUserObject(name: session[Constants.SessionKeys.userName], email: session[Constants.SessionKeys.userEmail], id: userId)
//    }
}

struct NoContextCommonViewContext: ViewContext {
    var common: CommonViewContext?
}

struct ErrorViewContext: ViewContext {
    var common: CommonViewContext?
    var error: String
    
    init(error: String) {
        self.error = error
    }
}
