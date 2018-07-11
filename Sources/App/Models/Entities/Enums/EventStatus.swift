import Vapor

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

extension EventStatus: Content {}
