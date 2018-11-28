import Vapor
import Leaf
import Authentication
import FluentMySQL

extension CoursesController: RouteCollection {
    func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("courses", use: courses)
        authedRouter.get("courses", "join", use: showJoinForm)
        authedRouter.post("courses", "join", use: join)
        authedRouter.get("courses", Course.parameter, use: showTopics)
        authedRouter.get("courses", Course.parameter, "topics", Int.parameter, Int.parameter, use: showTopicItem)
    }
}

final class CoursesController {
    
    func courses(_ request: Request) throws -> Future<View> {
        return try request.requireSessionUser().flatMap { user in
            let publishedCourses = try user.courses.query(on: request).filter(\.status == PublishStatus.published).all()
            let archivedCourses = try user.courses.query(on: request).filter(\.status == PublishStatus.archived).all()
            let draftCourses = try user.courses.query(on: request).filter(\.status == PublishStatus.draft).all()
            let leaf = try request.make(LeafRenderer.self)
            let context = CoursesViewContext(user: user, publishedCourses: publishedCourses, archivedCourses: archivedCourses, draftCourses: draftCourses)
            return leaf.render("Courses/courses", context, request: request)
        }
    }
    
    func showJoinForm(_ request: Request) throws -> Future<View> {
        let leaf = try request.privateContainer.make(LeafRenderer.self)
        return leaf.render("Courses/join", request: request)
    }
    
    func join(_ request: Request) throws -> Future<Response> {
        return try request.content.decode(JoinRequest.self).map { joinRequest in
            return joinRequest.joinCode
        }.flatMap { joinCode in
            return Course.query(on: request).filter(\.joinCode == joinCode).first().flatMap { course in
                guard let course = course else {
                    return request.future(request.redirect(to: "/courses/join").flash(.error, "Invalid code"))
                }
                return try request.requireSessionUser().flatMap { user in
                    let cm = CourseMember(courseID: course.id!, userID: user.id!, role: .student)
                    return cm.save(on: request).flatMap { _ in
                        return request.future(request.redirect(to: "/courses"))
                    }
                }
            }
            
        }
    }
    
    private func isVisible(user: User, course: Course, on connectable: DatabaseConnectable) -> Future<Bool> {
        if course.isEditable(to: user) {
            return connectable.future(true)
        }
        return CourseMember.query(on: connectable).filter(\.userID == user.id!).filter(\.courseID == course.id!)
            .count().map { $0 > 0 }
    }
    
    func showTopics(request: Request) throws -> Future<Response> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            return self.isVisible(user: user, course: course, on: request).flatMap { isVisible in
                guard isVisible else {
                    throw Abort(.unauthorized)
                }
                
                let topicsFuture = try course.topics.query(on: request).sort(\Topic.sequence).all()
                
                let context = TopicsViewContext(course: course, topics: topicsFuture)
                let leaf = try request.make(LeafRenderer.self)
                return try leaf.render("Courses/course", context, request: request).encode(for: request)
            }
        }
    }
    
    
    func showTopicItem(request: Request) throws -> Future<Response> {
        let courseFuture = try request.parameters.next(Course.self)
        let topicSequence = try request.parameters.next(Int.self)
        let topicItemSequence = try request.parameters.next(Int.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            return self.isVisible(user: user, course: course, on: request).flatMap { isVisible in
                guard isVisible else {
                    throw Abort(.unauthorized)
                }
                
                let courseTopicFuture = try course.topics.query(on: request).filter(\Topic.sequence == topicSequence).first().unwrap(or: Abort(.notFound))
                
                return courseTopicFuture.flatMap { (topic) in
                    let topicItemFuture = TopicItem.query(on: request).filter(\.topicID == topic.id!).filter(\.sequence == topicItemSequence).first().unwrap(or: Abort(.notFound))
                    let nextPage = "/courses/\(course.id!)/topics/\(topicSequence)/\(topicItemSequence+1)"
                    let previousPage = "/courses/\(course.id!)/topics/\(topicSequence)/\(topicItemSequence-1)"
                    let numberOfPages = TopicItem.query(on: request).filter(\.topicID == topic.id!).count()
                    
                    return topicItemFuture.flatMap { topicItem in
                        let context: TopicItemViewContext
                        if let problemID = topicItem.problemID {
                            let problemFuture = Problem.find(problemID, on: request).unwrap(or: Abort(.notFound))
                            let problemCasesFuture = ProblemCase.query(on: request).filter(\.problemID == problemID).filter(\.visibility == ProblemCaseVisibility.show).all()
                            context = TopicItemViewContext(course: course, topic: topic, topicItem: topicItemFuture, nextPage: nextPage, previousPage: previousPage, numberOfPages: numberOfPages, problem: problemFuture, problemCases: problemCasesFuture)
                        }
                        else {
                            context = TopicItemViewContext(course: course, topic: topic, topicItem: topicItemFuture, nextPage: nextPage, previousPage: previousPage, numberOfPages: numberOfPages)
                        }
                        let leaf = try request.make(LeafRenderer.self)
                        return try leaf.render("Courses/topicItem", context, request: request).encode(for: request)
                    }
                }
            }
        }
    }
}

fileprivate struct CoursesViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let user: User
    let publishedCourses: Future<[Course]>
    let archivedCourses: Future<[Course]>
    let draftCourses: Future<[Course]>
    
    init(user: User, publishedCourses: Future<[Course]>, archivedCourses: Future<[Course]>, draftCourses: Future<[Course]>) {
        self.user = user
        self.publishedCourses = publishedCourses
        self.archivedCourses = archivedCourses
        self.draftCourses = draftCourses
    }
}

fileprivate struct TopicsViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let course: Course
    let topics: Future<[Topic]>
    
    init(course: Course, topics: Future<[Topic]> ) {
        self.course = course
        self.topics = topics
        
    }
}

fileprivate struct TopicItemViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let course: Course
    let topic: Topic
    let topicItem: Future<TopicItem>
    let nextPage: String
    let previousPage: String
    let numberOfPages: Future<Int>
    let problem: Future<Problem>?
    let problemCases: Future<[ProblemCase]>?
    
    init(course: Course, topic: Topic, topicItem: Future<TopicItem>, nextPage: String, previousPage: String, numberOfPages: Future<Int>, problem: Future<Problem>? = nil, problemCases: Future<[ProblemCase]>? = nil) {
        self.course = course
        self.topic = topic
        self.topicItem = topicItem
        self.nextPage = nextPage
        self.previousPage = previousPage
        self.numberOfPages = numberOfPages
        self.problem = problem
        self.problemCases = problemCases
    }
}

fileprivate struct JoinRequest: Content {
    var joinCode: String
}

