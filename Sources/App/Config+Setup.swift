import LeafProvider
import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        
        addPreparations()
        
//        if shouldSeed() {
//            try seed()
//        }
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
    }
    
    private func addPreparations() {
        preparations.append(Problem.self)
        preparations.append(User.self)
    }
    
    private func shouldSeed() -> Bool {
        return true
    }
    
    private func seed() throws {
        try Problem(name: "Test", language: "Swift").save()
    }
}
