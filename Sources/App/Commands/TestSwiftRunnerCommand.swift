import Vapor
import Console

final class TestSwiftRunnerCommand: Command {
    
    public let id = "swiftrunner"
    public let help = ["Test we can call the swift runner."]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public func run(arguments: [String]) throws {
        let problemCase1 = ProblemCase(input: "", output: "Hello Mor Nor", problemID: 1)
        problemCase1.id = 1
        let problemCase2 = ProblemCase(input: "Hello", output: "Hey Mor Nor", problemID: 1)
        problemCase2.id = 2
        
        let submission = Submission(eventProblemID: 1, userID: 1, files: ["hello.swift"])
        submission.id = "test"
            
        let result = SwiftRunner(console: console).process(submission: submission, problemCases: [problemCase1, problemCase2])
        
        switch result {
        case .compileFailure(let compilerOutput):
            console.print("Compile failed:")
            console.print(compilerOutput)
        case .unknownFailure:
            console.print("Unknown failure")
        case .success(let resultCases):
            console.print("Success")
            for resultCase in resultCases {
                console.print("Case pass: \(resultCase.pass)")
            }
        }

    }
    
}

extension TestSwiftRunnerCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        self.init(console: try config.resolveConsole())
    }
}
