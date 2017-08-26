import Foundation
import Console

class JavaRunner: Runner {
    
    let console: ConsoleProtocol
    let fileSystem: FileSystem
    let compilationPath: String
    
    public init(console: ConsoleProtocol = Terminal(arguments: []), fileSystem: FileSystem = FileSystem()) {
        self.console = console
        self.fileSystem = fileSystem
        self.compilationPath = fileSystem.compilationPath() // TODO: pass in worker id in case we use shared filesystem
    }
    
    let javacPath = "/usr/bin/javac"
    let javaPath = "/usr/bin/java"
    
    func process(submission: Submission, problemCases: [ProblemCase]) -> RunnerResult {
        
        console.print("Copying uploads to compilation path")
        
        let uploadPath = fileSystem.uploadPath(submission: submission)
        fileSystem.ensurePathExists(path: compilationPath)
        fileSystem.clearContentsAtPath(path: compilationPath)
        for file in submission.files {
            if !fileSystem.copyFile(from: uploadPath + file, to: compilationPath + file) {
                return .unknownFailure
            }
        }
        
        console.print("Compiling")
        
        let sourcePaths = submission.files.map { compilationPath + $0 }
        let compileResult = compile(paths: sourcePaths)
        if !compileResult.success {
            return .compileFailure(compileResult.output)
        }
        
        // Determine which class has the main method
        let mainClass = stripFileExtension(submission.files.first!)
        
        console.print("Running test cases")
        
        var resultCases: [ResultCase] = []
        
        for problemCase in problemCases {
            let result = run(input: problemCase.input, mainClass: mainClass)
            let resultCase = ResultCase(submissionID: submission.id!, problemCaseID: problemCase.id!, output: result.output, pass: result.success && trim(result.output) == problemCase.output)
            print("Result case: \(result.success) \(result.exitStatus) \(result.output)")
            resultCases.append(resultCase)
        }
        
        return .success(resultCases)
    }
    
    // MARK: compilation and run methods
    
    private func compile(paths: [String]) -> ShellResult {
        return shell(launchPath: javacPath, arguments: paths)
    }
    
    private func run(input: String, mainClass: String) -> ShellResult {
        // Create the input file
        let inputFile = compilationPath + "input.txt"
        _ = fileSystem.save(string: input, path: inputFile)
        
        return shell(launchPath: "/usr/bin/timeout", arguments: ["1s", "/bin/bash", "-c", "cd \(compilationPath) ; ( cat \(inputFile) | \(javaPath) \(mainClass) )"])
    }
    
    // grep -HilR  "public[[:space:]+]static[[:space:]+][^v]*void[[:space:]+]main([^S)]\+String" .
    
    func stripFileExtension(_ filename: String) -> String {
        var components = filename.components(separatedBy: ".")
        guard components.count > 1 else { return filename }
        components.removeLast()
        return components.joined(separator: ".")
    }
    
}
