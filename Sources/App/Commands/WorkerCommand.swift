import Vapor
import Console

final class WorkerCommand: Command {
    
    var arguments: [CommandArgument] {
        return []
    }
    
    var options: [CommandOption] {
        return []
    }
    
    var help: [String] {
        return ["Starts a worker process."]
    }
    
    func run(using context: CommandContext) throws -> Future<Void> {
        context.console.print("Running the worker")
        return RedisWorker(console: context.console).run(on: context.container)
    }
}
