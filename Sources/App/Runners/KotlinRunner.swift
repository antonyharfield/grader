import Foundation
import Console

class KotlinRunner: Runner {
    
    let console: Console
    let fileSystem: FileSystem
    let compilationPath: String
    
    public init(console: Console = Terminal(), fileSystem: FileSystem = FileSystem()) {
        self.console = console
        self.fileSystem = fileSystem
        self.compilationPath = fileSystem.compilationPath() // TODO: pass in worker id in case we use shared filesystem
    }
    
    let kotlincPath = "/usr/bin/kotlinc"
    let javaPath = "/usr/bin/java"
    
    func getCompilationPath(fileName: String, uploadPath: String, compilationPath: String) -> String {
        let compilationLocation = compilationPath + fileName
        fileSystem.ensurePathExists(at: compilationPath)
        return compilationLocation
    }
    
    func process(submission: Submission, problemCases: [ProblemCase], comparisonMethod: ComparisonMethod) -> RunnerResult {
        
        console.print("Copying uploads to compilation path")
        
        let uploadPath = fileSystem.submissionUploadPath(submission: submission)
        fileSystem.ensurePathExists(at: compilationPath)
        fileSystem.clearContentsAtPath(path: compilationPath)
        
        let compilationPaths = submission.filesArray.map { (uploadPath + $0, getCompilationPath(fileName: $0, uploadPath: uploadPath, compilationPath: compilationPath)) }
        for (source, destination) in compilationPaths {
            console.print("\(source) => \(destination)")
            if !fileSystem.copyFile(from: source, to: destination) {
                return .unknownFailure
            }
        }
        
        console.print("Compiling")
        
        let sourcePaths = compilationPaths.map { $0.1 }
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
            print("Result case: \(result.success) \(result.exitStatus) \(result.output)")
            resultCases.append(resultCase)
        }
        
        return .success(resultCases)
    }
    
    // MARK: compilation and run methods
    
    private let jarFile = "run.jar"
    
    private func compile(paths: [String]) -> ShellResult {
        return shell(launchPath: kotlincPath, arguments: paths + ["-include-runtime", "-d", compilationPath + jarFile])
    }
    
    private func run(input: String) -> ShellResult {
        // Create the input file
        let inputFile = compilationPath + "input.txt"
        _ = fileSystem.save(string: input, path: inputFile)
        
        return shell(launchPath: "/usr/bin/timeout", arguments: ["1s", "/bin/bash", "-c", "cd \(compilationPath) ; ( cat \(inputFile) | \(javaPath) -jar \(compilationPath + jarFile) )"])
    }

}

