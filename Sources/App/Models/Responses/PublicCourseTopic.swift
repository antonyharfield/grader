import Vapor

struct PublicCourseTopic: Content {
    let id: Int?
    let sequence: Int
    let topic: Topic
}

extension PublicCourseTopic {
    init(courseTopic ep: CourseTopic, topic p: Topic) {
        self.init(id: ep.id, sequence: ep.sequence, topic: p)
    }
}
