import Node

enum SubmissionState: Int {
    
    case submitted = 0
    case gradingInProgress = 10
    case runnerError = 11
    case compileFailed = 20
    case graded = 30
    
}

extension SubmissionState: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        return Node(self.rawValue)
    }
}
