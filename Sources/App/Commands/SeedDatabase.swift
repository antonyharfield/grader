import Vapor
import Console

final class SeedCommand: Command {
    
    public let id = "seed"
    public let help = ["Seed the database."]
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public func run(arguments: [String]) throws {
        
        try deleteAll()
        try insertUsers()
        try insertProblems()
        try insertEvents()
    }
    
    private func deleteAll() throws {
        try User.all().forEach { try $0.delete() }
        try Problem.all().forEach { try $0.delete() }
    }
    
    private func insertProblems() throws {
        let problem1 = Problem(name: "Hello", description: "Print \"Hello Mor Nor\" (without quotes).", order: 10)
        try problem1.save()
        try ProblemCase(input: "", output: "Hello Mor Nor", problemID: problem1.id).save()
        
        let problem2 = Problem(name: "Fibonacci", description: "Print the Fibonacci sequence. The number of items to print is determined by an integer read in on the input.", order: 20)
        try problem2.save()
        try ProblemCase(input: "3", output: "1 1 2", problemID: problem2.id).save()
        try ProblemCase(input: "8", output: "1 1 2 3 5 8 13 21", problemID: problem2.id).save()
        try ProblemCase(input: "1", output: "1", problemID: problem2.id).save()
        try ProblemCase(input: "0", output: "", problemID: problem2.id).save()
        
        let problem3 = Problem(name: "FizzBuzz 4.0", description: "Print FizzBuzz from 1 to 20. Read the Fizz value and the Buzz value from the input.", order: 30)
        try problem3.save()
        try ProblemCase(input: "0", output: "", problemID: problem3.id).save()
    }
    
    private func insertUsers() throws {
        let admin = User(name: "Administrator", username: "admin", password: "1234", role: .admin)
        
        let student1 = User(name: "Arya Stark", username: "student1", password: "1234", role: .student)
        try student1.save()
        
        let student2 = User(name: "Jon Snow", username: "student2", password: "1234", role: .student)
        try student2.save()
    }
    
    private func insertEvents() throws {
        
    }
}

extension SeedCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        self.init(console: try config.resolveConsole())
    }
}
