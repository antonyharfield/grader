import Foundation
import Node

class FileSystem {
    
    // TODO: use drop.configUrl
    private let defaultEventFilesPath = "/app/uploads/events/"
    private let defaultSubmissionsPath = "/app/uploads/submissions/"
    private let defaultProblemFilesPath = "/app/uploads/problems/"
    private let defaultUserPath = "/app/uploads/users/"
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
    
    func eventFilesPath(event: Event) -> String {
        let eventFolderName = event.id?.string ?? ""
        return defaultEventFilesPath + eventFolderName + "/"
    }
    
    func submissionUploadPath(submission: Submission) -> String {
        let submissionFolderName = submission.id?.string ?? ""
        return defaultSubmissionsPath + submissionFolderName + "/"
    }
    
    func problemFilesPath(problemID: Identifier) -> String {
        let problemFolderName = problemID.string ?? ""
        return defaultProblemFilesPath + problemFolderName + "/"
    }

    func userProfileImagePath(user: User) -> String {
        let userID = user.id?.string ?? ""
        let directory = defaultUserPath + userID + "/"
        ensurePathExists(path: directory)
        return directory + "profile.jpg"
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
    
    func files(at path: String) -> [String] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            return []
        }
        return try! fileManager.contentsOfDirectory(atPath: path)
    }
    
    func copyFile(from: String, to: String) -> Bool {
        return shell(launchPath: "/bin/cp", arguments: [from, to]).success
    }
    
}
