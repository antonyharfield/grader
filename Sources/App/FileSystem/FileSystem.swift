import Foundation
import Node

class FileSystem {
    
    private let defaultUploadsPath = "/app/uploads/"
    private let defaultCompilationPath = "/app/srctest/"
    
    // TODO: pass in some configuration that allows custom paths
    init() {
        
    }
    
    func save(bytes: [UInt8], path: String) -> Bool {
        let pointer = UnsafeBufferPointer(start: bytes, count: bytes.count)
        let data = Data(buffer: pointer)
        do {
            try data.write(to: URL(fileURLWithPath: path))
        }
        catch {
            return false
        }
        return true
    }
    
    func save(string: String, path: String) -> Bool {
        do {
            try string.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
        } catch {
            print("error writing to url: \(path)\n\(error)")
            return false
        }
        return true
    }
    
    func uploadPath(submission: Submission) -> String {
        let submissionFolderName = submission.id?.string ?? "test"
        return defaultUploadsPath + submissionFolderName + "/"
    }
    
    func compilationPath(workerID: Identifier? = nil) -> String {
        let workerFolderName = workerID?.string ?? "test"
        return defaultCompilationPath + workerFolderName + "/"
    }
    
    func clearContentsAtPath(path: String) {
        // TODO: delete all the files (not including the directory)
        let fileManager = FileManager.default
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: path)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: path + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func ensurePathExists(path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return
        }
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        } catch {
            print("Could not create folder: \(error)")
        }
    }
    
    func copyFile(from: String, to: String) -> Bool {
        return shell(launchPath: "/bin/cp", arguments: [from, to]).success
    }
    
}
