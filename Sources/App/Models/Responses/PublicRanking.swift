import Vapor

struct PublicRanking: Content {
    let user: PublicUser
    let score: Int
    let totalPassed: Int
    let totalTimeMinutes: Int
    let attempts: Int
    let lastSolvedAt: Date
    let lastAttemptAt: Date
    let problems: Int
}

//extension PublicRanking {
//    init(user: PublicUser, score: Int, totalPassed: Int, totalTimeMinutes: Int, attempts: Int, lastSolvedAt: Date, lastAttemptAt: Date, problems: Int) {
//        self.user = user
//        self.score = score
//        self.totalPassed = totalPassed
//        self.totalTimeMinutes = totalTimeMinutes
//        self.attempts = attempts
//        self.lastSolvedAt = lastSolvedAt
//        self.lastAttemptAt = lastAttemptAt
//        self.problems = problems
//    }
//}
