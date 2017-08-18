import Foundation

func shell(launchPath: String, arguments: [String] = []) -> ShellResult {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    task.waitUntilExit()
    return ShellResult(exitStatus: task.terminationStatus, output: output)
}

struct ShellResult {
    let exitStatus: Int32
    let output: String
    var success: Bool {
        return exitStatus == 0
    }
}
