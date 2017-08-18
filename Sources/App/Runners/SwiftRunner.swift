import Foundation
import Console

class SwiftRunner: Runner {
    
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    let swiftcPath = "/usr/bin/swiftc"
    
    let sourcesPath = "/app/uploads/"
    let compilePath = "/app/srctest/"
    let executableFileName = "run"
    
    func process(submission: Submission, problemCases: [ProblemCase]) -> RunnerResult {
        
        let inputPath = compilePath + "hello.swift" // TODO: get from submission
        
        console.print("Copying source file to: \(inputPath)")
        
        guard copyFile(from: sourcesPath + "hello.swift", to: inputPath) else {
            return .unknownFailure
        }
        
        console.print("Compiling")
        
        let compileResult = compile(paths: [inputPath])
        if !compileResult.success {
            return .compileFailure(compileResult.output)
        }
        
        console.print("Running test cases")
        
        for problemCase in problemCases {
            let result = run(input: problemCase.input)
            
            console.print("Expected: \(problemCase.output)")
            console.print("Actual: \(result.output)")
            
            if result.success && trim(result.output) == problemCase.output {
                console.print("Problem case passed")
            }
            else {
                console.print("Problem case failed")
            }
        }
        
        return .success
    }
    
    // MARK: compilation and run methods
    
    private func compile(paths: [String]) -> ShellResult {
        return shell(launchPath: swiftcPath, arguments: ["-o", compilePath+executableFileName] + paths)
    }
    
    private func run(input: String) -> ShellResult {
        let inputFile = compilePath + "input.txt"
        _ = createFile(path: inputFile, content: input)
        return shell(launchPath: "/bin/bash", arguments: ["-c", "cat \(inputFile) | \(compilePath)\(executableFileName)"])
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
    
    // MARK: string utility methods
    
    private func trim(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
