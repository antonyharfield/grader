import Node

enum Language: String {
    case swift = "swift"
    case java = "java"
}

extension Language: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        return Node(self.rawValue)
    }
}
