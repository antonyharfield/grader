enum Role: Int {
    case student = 1
    case teacher = 2
    case admin   = 3
}

extension Role {
    
    private var permissions: [Permission] {
        switch self {
            case .admin: return [.administrate]
            case .teacher: return [.teach]
            default: return []
        }
    }
    
    var permitted: [Permission] {
        return self.permissions.flatMap { $0.implied }
    }
    
    func permits(_ permission: Permission) -> Bool {
        return permitted.contains(permission)
    }
    
}
