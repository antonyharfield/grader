import Vapor

enum ComparisonMethod: String {
    case exactMatch = "exactMatch"
    case endsWith = "endsWith"
}

extension ComparisonMethod: Content {}

extension ComparisonMethod: CaseIterable, ReflectionDecodable {
    static var allCases: [ComparisonMethod] {
        return [.exactMatch, .endsWith]
    }
}
