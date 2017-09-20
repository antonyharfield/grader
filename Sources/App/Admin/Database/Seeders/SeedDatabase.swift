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
        
        let problem5 = Problem(name: "Semi-Diagonal Alphabet", description: "First, you take the position of the letter in the alphabet, P (P is 1-indexed here). Then, you print each letter until the input (inclusive) on a line, preceded by P-1 and repeat that letter P times, interleaving with spaces.")
        try problem5.save()
        try ProblemCase(input: "A", output: "A", problemID: problem5.id).save()
        try ProblemCase(input: "B", output: "A\n B B", visible: true, problemID: problem5.id).save()
        try ProblemCase(input: "F", output: "A\n B B\n  C C C\n   D D D D\n    E E E E E\n     F F F F F F", visible: true, problemID: problem5.id).save()
        try ProblemCase(input: "K", output: "A\n B B\n  C C C\n   D D D D\n    E E E E E\n     F F F F F F\n      G G G G G G G\n       H H H H H H H H\n        I I I I I I I I I\n         J J J J J J J J J J\n          K K K K K K K K K K K", problemID: problem5.id).save()
        
        let problem6 = Problem(name: "Palindrome Numbers", description: "Read in a number and check if it is a palindrome or not.")
        try problem6.save()
        try ProblemCase(input: "1221", output: "true", visible: true, problemID: problem6.id).save()
        try ProblemCase(input: "3345433", output: "true", visible: true, problemID: problem6.id).save()
        try ProblemCase(input: "1212", output: "false", visible: true, problemID: problem6.id).save()
        try ProblemCase(input: "98712421789", output: "true", problemID: problem6.id).save()
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
    
    private func insertChaz() throws {
        // Teacher
        let chaz = User(name: "Charles Allen", username: "chaz", password: "cave of wonders", role: .teacher)
        try chaz.save()
        
        // Dump student users here
        let myClass: [(String, String, String)] = [
            ("58244888", "Punyapat Supakong", "dwe7qw"),
            ("58344281", "Kanokwan Noppakun", "w32mqb"),
            ("58344298", "Krit Fumin", "9cv6rx"),
            ("58344311", "Kollawat Sonchai", "ky92eg"),
            ("58344342", "Kittinan Sukkasem", "4dvuqn"),
            ("58344458", "Chanthaapha Chaemchon", "mc4cns"),
            ("58344519", "Nuttapong Laoanantasap", "szptc7"),
            ("58344526", "Natthamol Unboon", "a2d32d"),
            ("58344571", "Tawatpong Tongmuang", "cgdv64"),
            ("58344588", "Tarin Gurin", "erj9sb"),
            ("58344625", "Photsawee Phomsawat", "zxa8ed"),
            ("58344632", "Pittaya Pinmanee", "7dsbp2"),
            ("58344656", "Peerada Sornchai", "63vxya"),
            ("58344724", "Chavakorn Wongnuch", "p75wza"),
            ("58344748", "Siripron Muangprem", "p7e246"),
            ("58344779", "Sarawut Poree", "gvs5pr"),
            ("58344830", "Sumitta Siriwat", "4ce78s"),
            ("58344847", "Suranart Seemarksuk", "4z9v72"),
            ("58344854", "Saowalak Aeamsamang", "pbf5rq"),
            ("58344892", "Aniwat Prakart", "r3bza4"),
            ("58344915", "Areeya Aongsan", "dt9p5a"),
            ("58348005", "Suchada Rodthongdee", "af3753"),
            ("58364678", "Somrak Boonkerdma", "ngw75b"),
            ("58364692", "Sorawit Phuthirangsriwong", "rz25dp"),
            ("58344328", "Kanjana Healong", "u5va4f"),
            ("58344373", "Kasem Senket", "2sq6n3"),
            ("58344403", "Jinnipa Keschai", "2rejxq"),
            ("58344410", "Jiradet Bunyim", "s957zk"),
            ("58344427", "Jirawat Nutmee", "e69g3v"),
            ("58344434", "Jutamad Boonmark", "fa72s2"),
            ("58344441", "Jutamas Duangmalai", "jw5nbt"),
            ("58344465", "Channarong Rodthong", "rf2n7w"),
            ("58344472", "Chutipong Kitsanakun", "3cpa3k"),
            ("58344489", "Chaowat Thaiprayun", "fxcdq5"),
            ("58344496", "Tanawan Kietbunditkun", "3x74zs"),
            ("58344533", "Duangkamon Boonrot", "7ej6z5"),
            ("58344557", "Tanatip Kiawngam", "6j3q6t"),
            ("58344564", "Thanaruk Promchai", "x5kh34"),
            ("58344595", "Naratorn Payaksri", "76wge6"),
            ("58344649", "Pawis Fuenton", "gmu47t"),
            ("58344694", "Rattanawalee Songwattana", "rxzwm4"),
            ("58344700", "Ramet Natphu", "gqhs77"),
            ("58344717", "Laddawan Somrak", "7ezj99"),
            ("58344755", "Supanida Yatopama", "f9aedk"),
            ("58344762", "Sanphet Duanhkham", "6u3wz6"),
            ("58344786", "Savinee Thaworanant", "5a6h2j"),
            ("58344793", "Sitanan Rodcharoen", "82zbtd"),
            ("58344809", "Sirikhwan Homsuwan", "5yftnm"),
            ("58344816", "Sukanya Iambu", "7y8wbh"),
            ("58344823", "Suphattra Piluek", "e98tb9"),
            ("58344885", "Anonset Natsaphat", "5sy756"),
            ("58344908", "Anucha Kaewmongkonh", "aj7gk9"),
            ("58344922", "Aittiporn Meekaew", "m5yw73"),
            ("58344946", "Opas Sakulpram", "dx5upp"),
            ("58347930", "Chamaiporn Rhianthong", "e8thgk"),
            ("58347954", "Pornpan Rungsri", "v7xb6f"),
            ("58347961", "Patsakon Junvee", "wxrtu5"),
            ("58347978", "Pawin Potijinda", "69de5h"),
        ]
        
        // Save students
        for x in myClass {
            try User(name: x.1, username: x.0, password: x.2, role: .student).save()
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
        try EventProblem(eventID: event1.id!, problemID: problems[4].id!, sequence: 5).save()
        try EventProblem(eventID: event1.id!, problemID: problems[5].id!, sequence: 6).save()
        
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
        
        let submission1 = Submission(eventProblemID: problem.id!, userID: student.id!, language: .swift, files: ["hello.swift"], state: .compileFailed, compilerOutput: "Missing semicolon")
        try submission1.save()
        
        let submission2 = Submission(eventProblemID: problem.id!, userID: student.id!, language: .swift, files: ["hello.swift"], state: .graded, score: 200)
        try submission2.save()
        
        let submission3 = Submission(eventProblemID: problem.id!, userID: student.id!, language: .swift, files: ["hello.swift"], state: .submitted)
        try submission3.save()
        
        let submission4 = Submission(eventProblemID: problem.id!, userID: student.id!, language: .swift, files: ["hello.swift"], state: .submitted)
        try submission4.save()
    }
    
}

extension SeedCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        self.init(console: try config.resolveConsole())
    }
}
