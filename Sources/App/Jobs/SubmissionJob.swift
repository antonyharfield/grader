import Foundation
import Reswifq
import Node

public struct SubmissionJob: Job {
    
    let submissionID: Int
    
    // MARK: Initialization
    public init(submissionID: Int) {
        self.submissionID = submissionID
    }
    
    // MARK: Job
    public func perform() throws {
        try User(name: "test", username: "aaa", password: "1234", role: .student).save()
        
        guard let submission = try Submission.find(submissionID) else {
            return
        }
        
        try call(runner: SwiftRunner(), submission: submission)
    }
    
    private func call(runner: Runner, submission: Submission) throws {
        
        // Set the job state in progress
        submission.state = .gradingInProgress
        try submission.save()
        
        // Get the problem cases
        guard let problemCases = try submission.eventProblem.get()?.problem.get()?.cases.all() else {
            print("Problem with the data") // TODO: how to handle?
            submission.state = .runnerError
            try submission.save()
            return
        }
        
        let result = runner.process(submission: submission, problemCases: problemCases)
        
        switch result {
        case .unknownFailure:
            submission.state = .runnerError
        case .compileFailure(let compilerOutput):
            submission.state = .compileFailed
            submission.compilerOutput = compilerOutput
        case .success(let resultCases):
            for resultCase in resultCases {
                try resultCase.save()
            }
            submission.state = .graded
            submission.score = 100 * resultCases.reduce(0) { $0 + ($1.pass ? 1 : 0) } / resultCases.count
        }
        
        try submission.save()
    }
    
    // MARK: DataDecodable
    public init(data: Data) throws {
        
        let object = try JSONSerialization.jsonObject(with: data)
        
        guard let dictionary = object as? Dictionary<String, Any> else {
            throw DataDecodableError.invalidData(data)
        }
        
        guard let submissionID = dictionary["submissionID"] as? Int else {
            throw DataDecodableError.invalidData(data)
        }
        
        self.submissionID = submissionID
    }
    
    // MARK: DataEncodable
    public func data() throws -> Data {
        
        let object: [String: Any] = [
            "submissionID" : self.submissionID
        ]
        
        return try JSONSerialization.data(withJSONObject: object)
    }
}
