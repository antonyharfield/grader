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
        
        let uploadPath = fileSystem.submissionUploadPath(submission: submission)
        fileSystem.ensurePathExists(path: compilationPath)
        fileSystem.clearContentsAtPath(path: compilationPath)
        for file in submission.files {
            if !fileSystem.copyFile(from: uploadPath + file, to: compilationPath + file) {
                return .unknownFailure
            }
            print("Found \(file)")
        }
        
        console.print("Copying problem files to compilation path")
        
        let problemFilesPath = fileSystem.problemFilesPath(problemID: problemCases[0].problemID!)
        let problemFiles = fileSystem.files(at: problemFilesPath)
        for file in problemFiles {
            if !fileSystem.copyFile(from: problemFilesPath + file, to: compilationPath + file) {
                return .unknownFailure
            }
            print("Found \(file)")
        }
        
        console.print("Compiling")
        
        let sourcePaths = (submission.files.map { compilationPath + $0 }) + (problemFiles.map { problemFilesPath + $0 })
        let compileResult = compile(paths: sourcePaths)
        if !compileResult.success {
            return .compileFailure(compileResult.output)
        }
        
        console.print("Running test cases")
        
        var resultCases: [ResultCase] = []
        
        for problemCase in problemCases {
            let result = run(input: problemCase.input)
            let expectedOutput = prepareOutput(problemCase.output)
            let actualOutput = prepareOutput(result.output)
            let match = (comparisonMethod == .exactMatch)
                ? isExactMatch(expected: expectedOutput, actual: actualOutput)
                : isEndsWithMatch(expected: expectedOutput, actual: actualOutput)
            
            let resultCase = ResultCase(submissionID: submission.id!, problemCaseID: problemCase.id!, output: result.output, pass: result.success && match)
            print("Result: \(result.success) \(result.exitStatus) \(trim(result.output))   Match: \(match)")
            print("Problem case: \(trim(problemCase.input))")
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
