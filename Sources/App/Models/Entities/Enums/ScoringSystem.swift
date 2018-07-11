import Vapor

enum ScoringSystem: Int {
    
    //case none = 0
    case pointsThenLastCorrectSubmission = 1
    case pointsThenTotalTime = 2
    
    var string: String {
        switch self {
        //case .none:
        //    return "None"
        case .pointsThenLastCorrectSubmission:
            return "Points then Last Correct Submission"
        case .pointsThenTotalTime:
            return "Points then Total Time (ACM-ICPC, no penalty)"
        }
    }
    
    static var `default`: ScoringSystem = .pointsThenLastCorrectSubmission
}

extension ScoringSystem: Content {}

extension ScoringSystem: CaseIterable, ReflectionDecodable {
    static var allCases: [ScoringSystem] {
        return [.pointsThenLastCorrectSubmission, .pointsThenTotalTime]
    }
    

}
