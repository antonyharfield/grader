import Leaf

public class Add: Tag {
    public let name = "add"
    
    public func run(tagTemplate: TagTemplate, arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count == 2,
            let value1 = arguments[0]?.int,
            let value2 = arguments[1]?.int
            else { return nil }
        return Node(value1 + value2)
    }
}
