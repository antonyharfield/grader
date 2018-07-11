import Vapor

enum Language: String {
    case swift = "swift"
    case java = "java"
    case python = "python"
    case kotlin = "kotlin"
}

extension Language: Content {}

extension Language: CaseIterable, ReflectionDecodable {
    static var allCases: [Language] {
        return [.swift, .java, .python, .kotlin]
    }
}
