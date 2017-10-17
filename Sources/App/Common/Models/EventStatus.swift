import Node

enum EventStatus: Int {
    
    case draft = 1
    case published = 2
    case archived = 3
    
    var string: String {
        switch self {
        case .draft:
            return "Draft"
        case .published:
            return "Published"
        case .archived:
            return "Archived"
        }
    }
}

extension EventStatus: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        return try ["id": self.rawValue, "string": self.string].makeNode(in: context)
    }
}


