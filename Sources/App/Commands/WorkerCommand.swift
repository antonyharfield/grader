import Vapor
import Console

final class WorkerCommand: Command {
    
    public let id = "worker"
    public let help = ["Starts a worker process."]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public func run(arguments: [String]) throws {
        RedisWorker(console: console).run()
    }
    
}

extension WorkerCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
}
