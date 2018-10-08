import Vapor

struct PublicTopicItem: Content {
    let id: Int?
    let sequence: Int
    let problem: Problem
}

extension PublicTopicItem {
    init(topicItem ep: TopicItem, problem p: Problem) {
        self.init(id: ep.id, sequence: ep.sequence, problem: p)
    }
}


//import Vapor
//
//struct PublicTopicItem: Content {
//    let id: Int?
//    let sequence: Int
//    let item: Item
//}
//
//extension PublicTopicItem {
//    init(topicItem ep: TopicItem, item p: Item) {
//        self.init(id: ep.id, sequence: ep.sequence, item: p)
//    }
//}

