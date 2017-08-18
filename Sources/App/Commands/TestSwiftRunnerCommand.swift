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
        let problemCase2 = ProblemCase(input: "Hello", output: "Hello Mor Nor", problemID: 1)
            
        _ = SwiftRunner(console: console).process(submission: Submission(), problemCases: [problemCase1, problemCase2])
    }
    
}

extension TestSwiftRunnerCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        self.init(console: try config.resolveConsole())
    }
}
