import Vapor

struct SubmissionData: Content {
    let language: String?
    let file: File
}
