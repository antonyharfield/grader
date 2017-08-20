import Foundation
import Reswifq
import Node

public struct SubmissionJob: Job {
    
    let submissionID: Identifier
    
    // MARK: Initialization
    public init(submissionID: Identifier) {
        self.identifier = UUID().uuidString
        self.submissionID = submissionID
    }
    
    // MARK: Attributes
    public let identifier: String
    
    // MARK: Job
    public func perform() throws {
        
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
        
        guard let identifier = dictionary["identifier"] as? String, let submissionID = dictionary["submissionID"] as? Identifier else {
            throw DataDecodableError.invalidData(data)
        }
        
        self.identifier = identifier
        self.submissionID = submissionID
    }
    
    // MARK: DataEncodable
    public func data() throws -> Data {
        
        let object: [String: Any] = [
            "identifier": self.identifier,
            "submissionID" : self.submissionID.string!
        ]
        
        return try JSONSerialization.data(withJSONObject: object)
    }
}
