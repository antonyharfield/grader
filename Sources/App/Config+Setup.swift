import LeafProvider
import MySQLProvider
import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        
        addPreparations()
        addCommands()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
    }
    
    private func addPreparations() {
        preparations.append(User.self)
        preparations.append(Problem.self)
        preparations.append(ProblemCase.self)
        preparations.append(Event.self)
        preparations.append(EventProblem.self)
        preparations.append(Submission.self)
        preparations.append(ResultCase.self)
    }
    
    private func addCommands() {
        addConfigurable(command: WorkerCommand.init, name: "worker")
        addConfigurable(command: SeedCommand.init, name: "seed")
        addConfigurable(command: TestSwiftRunnerCommand.init, name: "swiftrunner")
    }
}
