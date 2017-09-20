import Leaf

class ArrayContains: BasicTag {

    public enum Error: Swift.Error {
        case expected2Arguments
        case expectedFirstArgumentArray
    }
    
    let name = "contains"
    
    public func run(arguments: ArgumentList) throws -> Node? {
        guard arguments.count == 2 else {
            throw Error.expected2Arguments
        }
        guard let _ = arguments[0]!.array else {
            throw Error.expectedFirstArgumentArray
        }
        return nil
    }
    
    public func shouldRender(tagTemplate: TagTemplate, arguments: ArgumentList, value: Node?) -> Bool {
        let array = arguments[0]!.array!
        let value = arguments[1]!
        for obj in array {
            if obj == value {
                return true
            }
        }
        return false
    }
}
