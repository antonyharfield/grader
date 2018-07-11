import Foundation

class FileSystem {
    
    // TODO: use drop.configUrl
    private static let root = "/Users/ant/Documents/Dev/agrader"
    private let defaultEventFilesPath = root+"/uploads/events/"
    private let defaultSubmissionsPath = root+"/uploads/submissions/"
    private let defaultProblemFilesPath = root+"/uploads/problems/"
    private let defaultUserPath = root+"/uploads/users/"
    private let defaultCompilationPath = root+"/srctest/"
    
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
        let eventFolderName = event.id.flatMap { String($0) } ?? ""
        return defaultEventFilesPath + eventFolderName + "/"
    }
    
    func submissionUploadPath(submission: Submission) -> String {
        let submissionFolderName = submission.id.flatMap { String($0) } ?? ""
        return defaultSubmissionsPath + submissionFolderName + "/"
    }
    
    func problemFilesPath(problemID: Int) -> String {
        let problemFolderName = String(problemID)
        return defaultProblemFilesPath + problemFolderName + "/"
    }

    func userFilesPath(user: User) -> String {
        let userFolderName = user.id.flatMap { String($0) } ?? ""
        return defaultUserPath + userFolderName + "/"
    }
    
    func userProfileImagePath(user: User) -> String {
        return userFilesPath(user: user) + "profile.jpg"
    }
    
    func compilationPath(workerID: Int? = nil) -> String {
        let workerFolderName = workerID.flatMap { String($0) } ?? "test"
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
