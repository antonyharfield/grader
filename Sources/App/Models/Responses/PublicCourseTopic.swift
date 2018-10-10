import Vapor

struct PublicCourseTopic: Content {
    let id: Int?
    let sequence: Int
    let topic: Topic
}

extension PublicCourseTopic {
    init(topic t: Topic) {
        self.init(id: t.id, sequence: t.sequence, topic: t)
    }
}
