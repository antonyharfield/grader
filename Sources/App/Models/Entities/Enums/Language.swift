import Vapor

enum Language: String {
    case swift = "swift"
    case java = "java"
    case python = "python"
    case kotlin = "kotlin"
}

extension Language: Content {}
