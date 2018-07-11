import Vapor

enum Permission: String {
    case teach, administrate
}

extension Permission {
    
    private var implies: [Permission] {
        switch self {
            case .administrate: return [.teach]
            default: return []
        }
    }
    
    var implied: [Permission] {
        return [self] + self.implies.flatMap { $0.implied }
    }
    
}

extension Permission: Content {}
