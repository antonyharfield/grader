import Node

enum Language: String {
    case swift = "swift"
    case java = "java"
    case python = "python"
}

extension Language: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        return Node(self.rawValue)
    }
}
