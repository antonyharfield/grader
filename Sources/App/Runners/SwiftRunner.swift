import Foundation
import Console

class SwiftRunner: Runner {
    
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol = Terminal(arguments: [])) {
        self.console = console
    }
    
    let swiftcPath = "/usr/bin/swiftc"
    
    let uploadsPath = "/app/uploads/"
    let compilationPath = "/app/srctest/"
    let executableFileName = "run"
    
    func process(submission: Submission, problemCases: [ProblemCase]) -> RunnerResult {
        
        console.print("Copying uploads to compilation path")
        
        // TODO: clear compilation path

        for file in submission.files {
            if !copyFile(from: uploadsPath + file, to: compilationPath + file) {
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
    
    // MARK: file utility methods
    
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
    
    private func clearFolder(path: String) {
        let fileManager = FileManager.default
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: path)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: path + filePath)
            }
        } catch {
            console.print("Could not clear temp folder: \(error)")
        }
    }
    
    // MARK: string utility methods
    
    private func trim(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
