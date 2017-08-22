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
        try ResultCase.all().forEach { try $0.delete() }
        try Submission.all().forEach { try $0.delete() }
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
        
        let problem2 = Problem(name: "Fibonacci", description: "Print the Fibonacci sequence. The number of items to print is determined by an integer read in on the input. If the input is 0 then print nothing.")
        try problem2.save()
        try ProblemCase(input: "3", output: "1 1 2", visible: true, problemID: problem2.id).save()
        try ProblemCase(input: "8", output: "1 1 2 3 5 8 13 21", problemID: problem2.id).save()
        try ProblemCase(input: "1", output: "1", problemID: problem2.id).save()
        try ProblemCase(input: "0", output: "", problemID: problem2.id).save()
        
        let problem3 = Problem(name: "FizzBuzz 4.0", description: "Print FizzBuzz from 1 to 20. Read the Fizz value and the Buzz value from the input.")
        try problem3.save()
        try ProblemCase(input: "3\n5", output: "1\n2\nFizz\n4\nBuzz\nFizz\n7\n8\nFizz\nBuzz\n11\nFizz\n13\n14\nFizzBuzz\n16\n17\nFizz\n19\nBuzz", visible: true, problemID: problem3.id).save()
        try ProblemCase(input: "6\n8", output: "1\n2\n3\n4\n5\nFizz\n7\nBuzz\n9\n10\n11\nFizz\n13\n14\n15\nBuzz\n17\nFizz\n19\n20", problemID: problem3.id).save()
        try ProblemCase(input: "10\n20", output: "1\n2\n3\n4\n5\n6\n7\n8\n9\nFizz\n11\n12\n13\n14\n15\n16\n17\n18\n19\nFizzBuzz", problemID: problem3.id).save()
        try ProblemCase(input: "10\n5", output: "1\n2\n3\n4\nBuzz\n6\n7\n8\n9\nFizzBuzz\n11\n12\n13\n14\nBuzz\n16\n17\n18\n19\nFizzBuzz", visible: true, problemID: problem3.id).save()
        
        let problem4 = Problem(name: "Plus Seven", description: "Read in a number, add 7, and print it out.")
        try problem4.save()
        try ProblemCase(input: "1", output: "8", visible: true, problemID: problem4.id).save()
        try ProblemCase(input: "9", output: "16", visible: true, problemID: problem4.id).save()
        try ProblemCase(input: "100", output: "107", problemID: problem4.id).save()
        try ProblemCase(input: "0", output: "7", problemID: problem4.id).save()
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
        
        let myClass: [(String, String)] = [("58312020", "Pimonrat Mayoo"),
                                           ("58313942", "Kamolporn Khankhai"),
                                           ("58313959", "Kamonphon Chaihan"),
                                           ("58313973", "Kettanok Yodsunthon"),
                                           ("58314024", "Julalak Phumket"),
                                           ("58314048", "Chanisara Uttamawetin"),
                                           ("58314062", "Titawan Laksukthom"),
                                           ("58314079", "Natdanai Phoopheeyo"),
                                           ("58314086", "Nattapon Phothima"),
                                           ("58314093", "Nattaphon Yooson"),
                                           ("58314109", "Nattawan Chomchuen"),
                                           ("58314116", "Nattawat Ruamsuk"),
                                           ("58314123", "Tuangporn Kaewchue"),
                                           ("58314130", "Tawanrung Keawjeang"),
                                           ("58314154", "Thodsaphon Phimket"),
                                           ("58314178", "Thanaphong Rittem"),
                                           ("58314185", "Thanaphon Wetchaphon"),
                                           ("58314192", "Thanawat Makenin"),
                                           ("58314222", "Tansiri Saetung"),
                                           ("58314246", "Thirakan Jeenduang"),
                                           ("58314277", "Nadia Nusak"),
                                           ("58314284", "Nitiyaporn Pormin"),
                                           ("58314321", "Bunlung Korkeattomrong"),
                                           ("58314338", "Patiphan Bunaum"),
                                           ("58314345", "Pathompong Jankom"),
                                           ("58314352", "Piyapong Ruengsiri"),
                                           ("58314369", "Pongchakorn Kanthong"),
                                           ("58314376", "Phongsiri Mahingsa"),
                                           ("58314406", "Phatcharaphon Naun-Ngam"),
                                           ("58314420", "Pittaya Boonyam"),
                                           ("58314444", "Peeraphon Khoeitui"),
                                           ("58314475", "Pakaporn Kiewpuampuang"),
                                           ("58314499", "Panusorn Banlue"),
                                           ("58314550", "Ronnachai Kammeesawang"),
                                           ("58314574", "Ratree Onchana"),
                                           ("58314581", "Lisachol Srichomchun"),
                                           ("58314628", "Vintaya Prasertsit"),
                                           ("58314642", "Witthaya Ngamprong"),
                                           ("58314659", "Winai Kengthunyakarn"),
                                           ("58314666", "Wisit Soontron"),
                                           ("58314697", "Sakchai Yotthuean"),
                                           ("58314703", "Sansanee Yimyoo"),
                                           ("58314710", "Siripaporn Kannga"),
                                           ("58314734", "Supawit Kiewbanyang"),
                                           ("58314741", "Supisara Wongkhamma"),
                                           ("58314789", "Suchada Buathong"),
                                           ("58314802", "Supicha Tejasan"),
                                           ("58314819", "Surachai Detmee"),
                                           ("58314826", "Surasit Yerpui"),
                                           ("58314840", "Athit Saenwaet"),
                                           ("58314857", "Anucha Thavorn"),
                                           ("58314864", "Apichai Noihilan"),
                                           ("58314895", "Akarapon Thaidee"),
                                           ("58314901", "Auravee Malha")]
        for x in myClass {
            try User(name: x.1, username: x.0, password: "1234", role: .student).save()
        }
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
        try EventProblem(eventID: event1.id!, problemID: problems[1].id!, sequence: 4).save()
        try EventProblem(eventID: event1.id!, problemID: problems[2].id!, sequence: 3).save()
        try EventProblem(eventID: event1.id!, problemID: problems[3].id!, sequence: 2).save()
        
//        let event2 = Event(name: "Swift Mini-test 1", userID: teacherID)
//        try event2.save()
//        try EventProblem(eventID: event2.id!, problemID: problems[1].id!, sequence: 2).save()
//        try EventProblem(eventID: event2.id!, problemID: problems[2].id!, sequence: 3).save()
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
