import Node

enum ScoringSystem: Int {
    
    case pointsThenLastCorrectSubmission = 1
    case pointsThenTotalTime = 2
    
    var string: String {
        switch self {
        case .pointsThenLastCorrectSubmission:
            return "Points then Last Correct Submission"
        case .pointsThenTotalTime:
            return "Points then Total Time (ACM-ICPC, no penalty)"
        }
    }
    
}

extension ScoringSystem: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        return try ["id": self.rawValue, "string": self.string].makeNode(in: context)
    }
}

