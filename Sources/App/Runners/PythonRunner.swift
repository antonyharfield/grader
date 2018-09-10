import Foundation
import Console

class PythonRunner: Runner {
    
    let console: Console
    let fileSystem: FileSystem
    let compilationPath: String
    
    public init(console: Console = Terminal(), fileSystem: FileSystem = FileSystem()) {
        self.console = console
        self.fileSystem = fileSystem
        self.compilationPath = fileSystem.compilationPath() // TODO: pass in worker id in case we use shared filesystem
    }
    
    let pythonPath = "/usr/bin/python3"
    
    func process(submission: Submission, problemCases: [ProblemCase], comparisonMethod: ComparisonMethod) -> RunnerResult {
        
        console.print("Copying uploads to test path")
        
        let uploadPath = fileSystem.submissionUploadPath(submission: submission)
        fileSystem.ensurePathExists(at: compilationPath)
        fileSystem.clearContentsAtPath(path: compilationPath)
        for file in submission.filesArray {
            if !fileSystem.copyFile(from: uploadPath + file, to: compilationPath + file) {
                return .unknownFailure
            }
            print("Found \(file)")
        }
        
        console.print("Copying problem files to test path")
        
        let problemFilesPath = fileSystem.problemFilesPath(problemID: problemCases[0].problemID)
        let problemFiles = fileSystem.files(at: problemFilesPath)
        for file in problemFiles {
            if !fileSystem.copyFile(from: problemFilesPath + file, to: compilationPath + file) {
                return .unknownFailure
            }
            print("Found \(file)")
        }
        
        // Python should be started with 1 file... need to determine which
        // ... if the problem has files then use that, else use the 1st file
        // in the submission
        let mainPath = problemFiles.count == 1 ? problemFilesPath + problemFiles[0] : compilationPath + submission.filesArray[0]
        
        console.print("Running test cases")
        
        var resultCases: [ResultCase] = []
        
        for problemCase in problemCases {
            let result = run(input: problemCase.input, sourcePath: mainPath)
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
    
    private func run(input: String, sourcePath: String) -> ShellResult {
        let inputFile = compilationPath + "input.txt"
        _ = fileSystem.save(string: input, path: inputFile)

        return shell(launchPath: "/usr/bin/timeout", arguments: ["1s", "/bin/bash", "-c", "cat \(inputFile) | \(pythonPath) \(sourcePath)"])
    }
    
}

