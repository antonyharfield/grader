import Vapor

enum SubmissionState: Int {
    
    case submitted = 0
    case gradingInProgress = 10
    case runnerError = 11
    case compileFailed = 20
    case graded = 30
    
    var string: String {
        switch self {
        case .submitted:
            return "Submitted"
        case .gradingInProgress:
            return "Grading in progress"
        case .runnerError:
            return "Runner error"
        case .compileFailed:
            return "Compile failed"
        case .graded:
            return "Graded"
        }
    }
}

extension SubmissionState: Content {}

extension SubmissionState: CaseIterable, ReflectionDecodable {
    static var allCases: [SubmissionState] {
        return [.submitted, .gradingInProgress, .runnerError, .compileFailed, .graded]
    }
}
