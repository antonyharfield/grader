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
        try EventProblem.all().forEach { try $0.delete() }
        try Event.all().forEach { try $0.delete() }
        try ProblemCase.all().forEach { try $0.delete() }
        try Problem.all().forEach { try $0.delete() }
        try User.all().forEach { try $0.delete() }
    }
    
    private func insertProblems() throws {
        let problem1 = Problem(name: "Hello", description: "Print \"Hello Mor Nor\" (without quotes).")
        try problem1.save()
        try ProblemCase(input: "", output: "Hello Mor Nor", visible: true, problemID: problem1.id).save()
        
        let problem2 = Problem(name: "Fibonacci", description: "Print the Fibonacci sequence. The number of items to print is determined by an integer read in on the input.")
        try problem2.save()
        try ProblemCase(input: "3", output: "1 1 2", visible: true, problemID: problem2.id).save()
        try ProblemCase(input: "8", output: "1 1 2 3 5 8 13 21", problemID: problem2.id).save()
        try ProblemCase(input: "1", output: "1", problemID: problem2.id).save()
        try ProblemCase(input: "0", output: "", problemID: problem2.id).save()
        
        let problem3 = Problem(name: "FizzBuzz 4.0", description: "Print FizzBuzz from 1 to 20. Read the Fizz value and the Buzz value from the input.")
        try problem3.save()
        try ProblemCase(input: "0", output: "", problemID: problem3.id).save()
    }
    
    private func insertUsers() throws {
        let admin = User(name: "Administrator", username: "admin", password: "1234", role: .admin)
        try admin.save()
        
        let teacher = User(name: "Antony Harfield", username: "ant", password: "1234", role: .teacher)
        try teacher.save()
        
        let student1 = User(name: "Arya Stark", username: "student1", password: "1234", role: .student)
        try student1.save()
        
        let student2 = User(name: "Jon Snow", username: "student2", password: "1234", role: .student)
        try student2.save()
    }
    
    private func insertEvents() throws {
        guard let teacher = try User.all().first, let teacherID = teacher.id else {
            console.print("Cannot find teacher or it's id")
            return
        }
        guard let problems = try? Problem.all(), problems.count >= 3 else {
            console.print("Problems not found")
            return
        }
        
        let event1 = Event(name: "Swift Warm-up (Week 2)", userID: teacherID)
        try event1.save()
        try EventProblem(eventID: event1.id!, problemID: problems[0].id!, sequence: 1).save()
        
        let event2 = Event(name: "Swift Mini-test 1", userID: teacherID)
        try event2.save()
        try EventProblem(eventID: event2.id!, problemID: problems[0].id!, sequence: 1).save()
        try EventProblem(eventID: event2.id!, problemID: problems[1].id!, sequence: 2).save()
        try EventProblem(eventID: event2.id!, problemID: problems[2].id!, sequence: 3).save()
    }
    
    private func insertSubmissions() throws {
        guard let student = try User.makeQuery().filter("role", Role.student.rawValue).first() else {
            console.print("Student not found")
            return
        }
        guard let problem = try EventProblem.makeQuery().first() else {
            console.print("Problem not found")
            return
        }
        
        let submission1 = Submission(eventProblemID: problem.id!, userID: student.id!, files: ["hello.swift"], state: .compileFailed, compilerOutput: "Missing semicolon")
        try submission1.save()
        
        let submission2 = Submission(eventProblemID: problem.id!, userID: student.id!, files: ["hello.swift"], state: .graded, score: 200)
        try submission2.save()
        
        let submission3 = Submission(eventProblemID: problem.id!, userID: student.id!, files: ["hello.swift"], state: .submitted)
        try submission3.save()
        
        let submission4 = Submission(eventProblemID: problem.id!, userID: student.id!, files: ["hello.swift"], state: .submitted)
        try submission4.save()
    }
    
}

extension SeedCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        self.init(console: try config.resolveConsole())
    }
}
