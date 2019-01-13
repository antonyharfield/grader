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
    
    func readPackage(filePath: String) -> String? {
        let url = URL(fileURLWithPath: filePath)
        let lines = try? String(contentsOf: url, encoding: String.Encoding.utf8)
        
        return lines?.components(separatedBy: CharacterSet.newlines)
            .first(where: { $0.hasPrefix("package") })
            .map { $0
                .substring(to: $0.index($0.endIndex, offsetBy: -1))
                .substring(from: $0.index($0.startIndex, offsetBy: 8))
        }
    }
    
    func readPackagePath(filePath: String) -> String? {
        return readPackage(filePath: filePath).map {
            $0.replacingOccurrences(of: ".", with: "/") + "/"
        }
    }
    
    func fileHasMainMethod(filePath: String) -> Bool {
        let keyword = "public static void main"
        let url = URL(fileURLWithPath: filePath)
        let lines = try? String(contentsOf: url, encoding: String.Encoding.utf8)
        return lines?.contains(keyword) ?? false
    }
    
    func getCompilationPath(fileName: String, uploadPath: String, compilationPath: String) -> String {
        let packagePath = readPackagePath(filePath: uploadPath + fileName) ?? ""
        let compilationLocation = compilationPath + packagePath + fileName
        fileSystem.ensurePathExists(path: compilationPath + packagePath)
        return compilationLocation
    }
    
    func process(submission: Submission, problemCases: [ProblemCase], comparisonMethod: ComparisonMethod) -> RunnerResult {
        
        console.print("Copying uploads to compilation path")
        
        let uploadPath = fileSystem.submissionUploadPath(submission: submission)
        fileSystem.ensurePathExists(path: compilationPath)
        fileSystem.clearContentsAtPath(path: compilationPath)
        
        let compilationPaths = submission.files.map { (uploadPath + $0, getCompilationPath(fileName: $0, uploadPath: uploadPath, compilationPath: compilationPath)) }
        for (source, destination) in compilationPaths {
            console.print("\(source) => \(destination)")
            if !fileSystem.copyFile(from: source, to: destination) {
                return .unknownFailure
            }
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
        
        let sourcePaths = compilationPaths.map { $0.1 } + (problemFiles.map { compilationPath + $0 })
        console.print("sourcePaths = \(sourcePaths.joined(separator: ", "))")
        let compileResult = compile(paths: sourcePaths)
        if !compileResult.success {
            return .compileFailure(compileResult.output)
        }
        
        // Determine which class has the main method
        let mainPath = sourcePaths.filter { fileHasMainMethod(filePath: $0) }.first ?? sourcePaths.first!
        console.print("mainPath = \(mainPath)")
        let mainFilename = mainPath.components(separatedBy: "/").last ?? mainPath
        console.print("mainFilename = \(mainFilename)")
        let mainPackage = readPackage(filePath: mainPath).map { $0 + "." } ?? ""
        let mainClass = stripFileExtension(mainPackage + mainFilename)
        
        console.print("Running test cases")
        
        var resultCases: [ResultCase] = []
        
        for problemCase in problemCases {
            let result = run(input: problemCase.input, mainClass: mainClass)
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
