import Vapor
import FluentMySQL

final class Problem: Content {
    
    var id: Int?
    var name: String
    var description: String
    var comparisonMethod: ComparisonMethod
    var comparisonIgnoresSpaces: Bool
    var comparisonIgnoresBreaks: Bool
    
    var cases: Children<Problem, ProblemCase> {
        return children(\.problemID)
    }
    
    init(id: Int? = nil, name: String, description: String, comparisonMethod: ComparisonMethod = .exactMatch, comparisonIgnoresSpaces: Bool = false, comparisonIgnoresBreaks: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.comparisonMethod = comparisonMethod
        self.comparisonIgnoresSpaces = comparisonIgnoresSpaces
        self.comparisonIgnoresBreaks = comparisonIgnoresBreaks
    }
}

extension Problem: MySQLModel {
    static let entity = "problems"
}

extension Problem: Parameter {}
