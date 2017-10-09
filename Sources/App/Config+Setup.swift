import LeafProvider
import MySQLProvider
import FluentProvider
import Flash

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        
        addMiddleware()
        addPreparations()
        addCommands()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
    }
    
    private func addMiddleware() {
        addConfigurable(middleware: FlashMiddleware(), name: "flash")
    }
    
    private func addPreparations() {
        // Initial Setup
        preparations.append(User.self)
        preparations.append(Problem.self)
        preparations.append(ProblemCase.self)
        preparations.append(Event.self)
        preparations.append(EventProblem.self)
        preparations.append(Submission.self)
        preparations.append(ResultCase.self)
        
        // Migrations
        preparations.append(P170924_ProblemCaseVisibility.self)
    }
    
    private func addCommands() {
        addConfigurable(command: WorkerCommand.init, name: "worker")
        addConfigurable(command: SeedCommand.init, name: "seed")
        addConfigurable(command: RunSubmissionJob.init, name: "submission")
        addConfigurable(command: TestSwiftRunnerCommand.init, name: "swiftrunner")
    }
}
