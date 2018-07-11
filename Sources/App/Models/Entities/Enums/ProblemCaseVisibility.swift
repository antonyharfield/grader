import Vapor

enum ProblemCaseVisibility: Int {
    case show = 1
    case hide = 2
    case debug = 3
}

extension ProblemCaseVisibility: Content {}
