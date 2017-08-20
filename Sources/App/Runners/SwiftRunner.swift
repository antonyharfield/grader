import Foundation
import Console

class SwiftRunner: Runner {
    
    let console: ConsoleProtocol
    let fileSystem: FileSystem
    let compilationPath: String
    
    public init(console: ConsoleProtocol = Terminal(arguments: []), fileSystem: FileSystem = FileSystem()) {
        self.console = console
        self.fileSystem = fileSystem
        self.compilationPath = fileSystem.compilationPath() // TODO: pass in worker id in case we use shared filesystem
    }
    
    let swiftcPath = "/usr/bin/swiftc"
    let executableFileName = "run"
    
    func process(submission: Submission, problemCases: [ProblemCase]) -> RunnerResult {
        
        console.print("Copying uploads to compilation path")
        
        let uploadPath = fileSystem.uploadPath(submission: submission)
        fileSystem.ensurePathExists(path: compilationPath)
        fileSystem.clearContentsAtPath(path: compilationPath)
        for file in submission.files {
            if !copyFile(from: uploadPath + file, to: compilationPath + file) {
                return .unknownFailure
            }
        }
        
        console.print("Compiling")
        
        let sourcePaths = submission.files.map { compilationPath + $0 }
        let compileResult = compile(paths: sourcePaths)
        if !compileResult.success {
            return .compileFailure(compileResult.output)
        }
        
        console.print("Running test cases")
        
        var resultCases: [ResultCase] = []
        
        for problemCase in problemCases {
            let result = run(input: problemCase.input)
            let resultCase = ResultCase(submissionID: submission.id!, problemCaseID: problemCase.id!, output: result.output, pass: result.success && trim(result.output) == problemCase.output)
            resultCases.append(resultCase)
        }
        
        return .success(resultCases)
    }
    
    // MARK: compilation and run methods
    
    private func compile(paths: [String]) -> ShellResult {
        return shell(launchPath: swiftcPath, arguments: ["-o", compilationPath+executableFileName] + paths)
    }
    
    private func run(input: String) -> ShellResult {
        let inputFile = compilationPath + "input.txt"
        _ = createFile(path: inputFile, content: input)
        return shell(launchPath: "/bin/bash", arguments: ["-c", "cat \(inputFile) | \(compilationPath)\(executableFileName)"])
    }
    
    // TODO: move file utility methods to FileSystem
    
    private func copyFile(from: String, to: String) -> Bool {
        return shell(launchPath: "/bin/cp", arguments: [from, to]).success
    }
    
    private func createFile(path: String, content: String) -> Bool {
        do {
            try content.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
        } catch {
            console.print("error writing to url: \(path)\n\(error)")
            return false
        }
        return true
    }
    
    // TODO: move submission comparison utility methods to somewhere shared between runners
    
    private func trim(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
