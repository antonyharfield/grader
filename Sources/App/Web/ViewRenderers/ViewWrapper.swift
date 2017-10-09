import Vapor


func render(_ viewName: String, _ data: [String: NodeRepresentable] = [:], for request: HTTP.Request, with renderer: ViewRenderer) throws -> View {
    var wrappedData = wrap(data, request: request)
    if let user = request.user {
        wrappedData = wrap(wrappedData, user: user)
    }
    return try renderer.make(viewName, wrappedData, for: request)
}

fileprivate func wrap(_ data: [String: NodeRepresentable], user: User) -> [String: NodeRepresentable] {
    var result = data

    result["authenticated"] = true
    result["authenticatedUser"] = user
    user.role.permitted.forEach { result["can\($0.rawValue.capitalized)"] = true }
    
    return result
}

fileprivate func wrap(_ data: [String: NodeRepresentable], request: HTTP.Request) -> [String: NodeRepresentable] {
    var result = data
    result["path"] = request.uri.path.components(separatedBy: "/").filter { $0 != "" }
    result["flash"] = try! request.storage["_flash"].makeNode(in: nil)
    return result
}
