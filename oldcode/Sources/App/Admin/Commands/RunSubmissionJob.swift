import Vapor
import Console

final class RunSubmissionJob: Command {
    
    public let id = "submission"
    public let help = ["Perform the submission job for a given submission"]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public func run(arguments: [String]) throws {
        guard arguments.count == 1, let id = Int(arguments[0]) else {
            console.print("Requires 1 argument (submission id)")
            return
        }
        let job = SubmissionJob(submissionID: id)
        try job.perform()
    }
    
}

extension RunSubmissionJob: ConfigInitializable {
    public convenience init(config: Config) throws {
        self.init(console: try config.resolveConsole())
    }
}
