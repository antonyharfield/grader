import Vapor
import Leaf
import Authentication

extension CoursesController: RouteCollection {
    func boot(router: Router) throws {
         let authedRouter = router.grouped(SessionAuthenticationMiddleware())
         authedRouter.get("courses", use: courses)
         authedRouter.get("courses", Course.parameter, use: showTopics)
        authedRouter.get("courses", Course.parameter, "topics", Int.parameter, Int.parameter, use: showTopicItem)
         //authedRouter.get("courses", Course.parameter, use: showTopicItem)


    }
}

    final class CoursesController {
    
    /// Returns the  page
    
        func courses(_ request: Request) throws -> Future<View> {
            return try request.requireSessionUser().flatMap { user in
            let courses = Course.query(on: request).sort(\.sequence, .ascending).all()
            let leaf = try request.make(LeafRenderer.self)
            return leaf.render("Courses/courses", CourseViewContext(user: user, courses: courses), request: request)
            }
        }
    }


    func showTopics(request: Request) throws -> Future<Response> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))

        print("test")
        return courseAndUserFuture.flatMap { (course, user) in
            guard course.isVisible(to: user) else {
                throw Abort(.unauthorized)
            }

            let topicsFuture = try course.courseTopics.query(on: request).sort(\.sequence)
                        .join(\Topic.id, to: \CourseTopic.topicID).alsoDecode(Topic.self).all()
                        .map { topics in
                            return topics.map { PublicCourseTopic(courseTopic: $0.0, topic: $0.1) }
            }

            let context = TopicsViewContext(course: course, topics: topicsFuture)
            let leaf = try request.make(LeafRenderer.self)
            return try leaf.render("Courses/course", context, request: request).encode(for: request)
        }
}
    

        func showTopicItem(request: Request) throws -> Future<Response> {
            let courseFuture = try request.parameters.next(Course.self)
            let topicSequence = try request.parameters.next(Int.self)
            let topicItemSequence = try request.parameters.next(Int.self)
            let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
            
            print("test")
            return courseAndUserFuture.flatMap { (course, user) in
               
                let courseTopicFuture = try course.courseTopics.query(on: request).filter(\.sequence == topicSequence).first().unwrap(or: Abort(.notFound))
                
                return courseTopicFuture.flatMap { (courseTopic) in
                    let topicFuture = Topic.find(courseTopic.topicID, on: request).unwrap(or: Abort(.notFound))
                    let topicItemFuture = TopicItem.query(on: request).filter(\.topicID == courseTopic.topicID).filter(\.sequence == topicItemSequence).first().unwrap(or: Abort(.notFound))
                    let nextPage = "/courses/\(course.id!)/topics/\(topicSequence)/\(topicItemSequence+1)"
                    let previousPage = "/courses/\(course.id!)/topics/\(topicSequence)/\(topicItemSequence-1)"
                    let pageAll = TopicItem.query(on: request, withSoftDeleted: true).count()
                    
                    return topicItemFuture.flatMap { topicItem in
                        let context: TopicItemViewContext
                        if let problemID = topicItem.problemID {
                            let problemFuture = Problem.find(problemID, on: request).unwrap(or: Abort(.notFound))
                            let problemCasesFuture = ProblemCase.query(on: request).filter(\.problemID == problemID).filter(\.visibility == ProblemCaseVisibility.show).all()
                            context = TopicItemViewContext(course: course, topic: topicFuture, topicItem: topicItemFuture, nextPage: nextPage, previousPage: previousPage, pageAll: pageAll, problem: problemFuture, problemCases: problemCasesFuture)
                        }
                        else {
                            context = TopicItemViewContext(course: course, topic: topicFuture, topicItem: topicItemFuture, nextPage: nextPage, previousPage: previousPage, pageAll: pageAll)
                        }
                        let leaf = try request.make(LeafRenderer.self)
                        return try leaf.render("Courses/topicItem", context, request: request).encode(for: request)
                    }
                }
        }
        
}

fileprivate struct CourseViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let user: User
    let courses: Future<[Course]>
    
    init(user: User, courses: Future<[Course]>) {
        self.user = user
        self.courses = courses
        
    }
}

fileprivate struct TopicsViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let course: Course
    let topics: Future<[PublicCourseTopic]>
    
    init(course: Course, topics: Future<[PublicCourseTopic]> ) {
        self.course = course
        self.topics = topics
      
    }
}

fileprivate struct TopicItemViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let course: Course
    let topic: Future<Topic>
    let topicItem: Future<TopicItem>
    let nextPage: String
    let previousPage: String
    let pageAll:EventLoopFuture<Int>
    let problem: Future<Problem>?
    let problemCases: Future<[ProblemCase]>?

    init(course: Course, topic: Future<Topic>, topicItem: Future<TopicItem>, nextPage: String, previousPage: String, pageAll:EventLoopFuture<Int>, problem: Future<Problem>? = nil, problemCases: Future<[ProblemCase]>? = nil) {
        self.course = course
        self.topic = topic
        self.topicItem = topicItem
        self.nextPage = nextPage
        self.previousPage = previousPage
        self.pageAll = pageAll
        self.problem = problem
        self.problemCases = problemCases
 
    }
}

