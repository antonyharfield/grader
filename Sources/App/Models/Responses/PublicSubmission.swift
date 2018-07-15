import Vapor

struct PublicSubmission: Content {
    let id: Int
    let language: Language
    let state: SubmissionState
    let score: Int
    let compilerOutput: String
    let createdAt: Date?
    let updatedAt: Date?
    
    let eventProblem: PublicEventProblem
    let user: PublicUser
}

extension PublicSubmission {
    init(submission s: Submission, eventProblem ep: EventProblem, problem p: Problem, user u: User) {
        self.init(id: s.id!, language: s.language, state: s.state,
            score: s.score, compilerOutput: s.compilerOutput,
            createdAt: s.createdAt, updatedAt: s.updatedAt,
            eventProblem: PublicEventProblem(eventProblem: ep, problem: p),
            user: PublicUser(user: u))
    }
}
