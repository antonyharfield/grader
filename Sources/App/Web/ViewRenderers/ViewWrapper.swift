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
    result["authenticatedUserHasTeacherRole"] = user.has(role: .teacher)
    return result
}

fileprivate func wrap(_ data: [String: NodeRepresentable], request: HTTP.Request) -> [String: NodeRepresentable] {
    var result = data
    let path: String = request.uri.path
    result["path"] = path.components(separatedBy: "/").filter { $0 != "" }
    return result
}
