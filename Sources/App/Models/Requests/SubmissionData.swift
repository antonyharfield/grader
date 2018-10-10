import Vapor

struct SubmissionData: Content {
    let eventProblemID: Int?
    let topicItemID: Int?
    let language: String?
    let file: File
}
