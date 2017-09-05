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
    
    func process(submission: Submission, problemCases: [ProblemCase], comparisonMethod: ComparisonMethod) -> RunnerResult {
        
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
        
        console.print("Running test cases")
        
        var resultCases: [ResultCase] = []
        
        for problemCase in problemCases {
            let result = run(input: problemCase.input)
            let match = (comparisonMethod == .exactMatch)
                ? isExactMatch(expected: problemCase.output, actual: result.output)
                : isEndsWithMatch(expected: problemCase.output, actual: result.output)
            
            let resultCase = ResultCase(submissionID: submission.id!, problemCaseID: problemCase.id!, output: result.output, pass: result.success && match)
            print("Result case: \(result.success) \(result.exitStatus) \(result.output)")
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
        _ = fileSystem.save(string: input, path: inputFile)
        //return shell(launchPath: "/bin/bash", arguments: ["-c", "cat \(inputFile) | \(compilationPath)\(executableFileName)"])
        return shell(launchPath: "/usr/bin/timeout", arguments: ["1s", "/bin/bash", "-c", "cat \(inputFile) | \(compilationPath)\(executableFileName)"])
    }
    
}
