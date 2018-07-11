import Async
import Leaf

public final class PrefixTag: TagRenderer {
    
    public init() {}
    
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(2)
        let string = tag.parameters[0].string ?? ""
        let prefix = tag.parameters[1].string ?? ""
        let result: TemplateData = .bool(string.hasPrefix(prefix))
        return Future.map(on: tag) { result }
    }
}
