import Foundation
import Reswifq
import Vapor

public struct SubmissionJob: Job {

    let submissionID: Int
    var eventLoopWorker: Vapor.Worker!
    
    // MARK: Initialization
    public init(submissionID: Int) {
        self.submissionID = submissionID
    }

    // MARK: Job
    public func perform(on eventLoopWorker: DatabaseConnectable) throws {
        guard let submission = try Submission.find(submissionID, on: eventLoopWorker) else {
            return
        }
        
        self.eventLoopWorker = eventLoopWorker

        let runner: Runner = chooseRunner(for: submission)
        try call(runner: runner, submission: submission)
    }

    private func chooseRunner(for submission: Submission) -> Runner {
        switch submission.language {
        case .swift:
            return SwiftRunner()
        case .java:
            return JavaRunner()
        case .python:
            return PythonRunner()
        case .kotlin:
            return KotlinRunner()
        }
    }

    private func call(runner: Runner, submission: Submission) throws {

        // Set the job state in progress
        submission.state = .gradingInProgress
        try submission.save()

        // Get the problem cases
        guard let problem = try submission.eventProblem.get()?.problem.get() else {
            print("Problem with the data") // TODO: how to handle?
            submission.state = .runnerError
            try submission.save()
            return
        }

        let problemCases = try problem.cases.all()
        let result = runner.process(submission: submission, problemCases: problemCases, comparisonMethod: problem.comparisonMethod)

        switch result {
        case .unknownFailure:
            submission.state = .runnerError
        case .compileFailure(let compilerOutput):
            submission.state = .compileFailed
            submission.compilerOutput = String(compilerOutput.prefix(255))
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
