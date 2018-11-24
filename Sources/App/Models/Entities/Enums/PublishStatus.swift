import Vapor

enum PublishStatus: Int {
    
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

extension PublishStatus: Content {}

extension PublishStatus: CaseIterable, ReflectionDecodable {
    static var allCases: [PublishStatus] {
        return [.draft, .published, .archived]
    }
}
