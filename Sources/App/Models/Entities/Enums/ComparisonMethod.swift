import Vapor

enum ComparisonMethod: String {
    case exactMatch = "exactMatch"
    case endsWith = "endsWith"
}

extension ComparisonMethod: Content {}
