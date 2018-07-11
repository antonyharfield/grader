import Vapor

struct PublicEventProblem: Content {
    let id: Int?
    let sequence: Int
    let problem: Problem
}

extension PublicEventProblem {
    init(eventProblem ep: EventProblem, problem p: Problem) {
        self.init(id: ep.id, sequence: ep.sequence, problem: p)
    }
}
