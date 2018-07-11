import Vapor

struct UserEventProblem: Content {
    let id: Int?
    let sequence: Int
    let problem: Problem
    let score: Int
    let attempts: Int
}
