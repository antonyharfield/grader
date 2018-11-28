import Vapor
import Leaf
import Authentication
import FluentMySQL

extension ManageCoursesController: RouteCollection {
    func boot(router: Router) throws {
        let teachRouter = router.grouped(SessionAuthenticationMiddleware(), GuardPermissionsMiddleware(.teach))
        teachRouter.get("courses", "new", use: showAdd)
        teachRouter.post("courses", "new", use: add)
        teachRouter.get("courses", Course.parameter, "edit", use: showEdit)
        teachRouter.post("courses", Course.parameter, "edit", use: edit)
        teachRouter.get("courses", Course.parameter, "topics", "new", use: showAddTopic)
        teachRouter.post("courses", Course.parameter, "topics", "new", use: addTopic)
    }
}

final class ManageCoursesController {
    
    func showAdd(_ request: Request) throws -> Future<View> {
        let leaf = try request.privateContainer.make(LeafRenderer.self)
        return leaf.render("Courses/Teacher/courseForm", request: request)
    }
    
    func add(_ request: Request) throws -> Future<Response> {
        let userID = request.cachedSessionUser()!.id!
        return try request.content.decode(CourseRequest.self).flatMap { courseRequest in
            
            if let joinCode = courseRequest.joinCode, joinCode != "" {
                return Course.query(on: request).filter(\.joinCode == joinCode).count().flatMap { count in
                    if count > 0 {
                        return request.future(request.redirect(to: "/courses/new").flash(.error, "Join code is not unique"))
                    }
                    return self.save(delta: courseRequest, userID: userID, request: request)
                }
            }
            
            return self.save(delta: courseRequest, userID: userID, request: request)
        }
    }
    
    func showEdit(request: Request) throws -> Future<View> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            guard course.isEditable(to: user) else {
                throw Abort(.unauthorized)
            }
            
            let context = CourseViewContext(course: course)
            let leaf = try request.make(LeafRenderer.self)
            return leaf.render("Courses/Teacher/courseForm", context, request: request)
        }
    }
    
    func edit(_ request: Request) throws -> Future<Response> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            guard course.isEditable(to: user) else {
                throw Abort(.unauthorized)
            }
            
            return try request.content.decode(CourseRequest.self).flatMap { courseRequest in
                
                if let joinCode = courseRequest.joinCode, joinCode != "" {
                    return Course.query(on: request).filter(\.id != course.id).filter(\.joinCode == joinCode).count().flatMap { count in
                        if count > 0 {
                            return request.future(request.redirect(to: "/courses/edit").flash(.error, "Join code is not unique"))
                        }
                        return self.save(oldCourse: course, delta: courseRequest, userID: user.id!, request: request)
                    }
                }
                
                return self.save(oldCourse: course, delta: courseRequest, userID: user.id!, request: request)
            }
        }
    }
    
    func showAddTopic(_ request: Request) throws -> Future<View> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            guard course.isEditable(to: user) else {
                throw Abort(.unauthorized)
            }
            
            let context = CourseViewContext(course: course)
            let leaf = try request.privateContainer.make(LeafRenderer.self)
            return leaf.render("Courses/Teacher/topicForm", context, request: request)
        }
    }
    
    func addTopic(_ request: Request) throws -> Future<Response> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            guard course.isEditable(to: user) else {
                throw Abort(.unauthorized)
            }
            return try request.content.decode(TopicRequest.self).flatMap { topicRequest in
                guard topicRequest.itemIDs.count == topicRequest.itemNames.count, topicRequest.itemIDs.count == topicRequest.itemTexts.count, topicRequest.itemIDs.count == topicRequest.itemProblemIDs.count else {
                    throw Abort(.internalServerError)
                }
                
                let topic = Topic(courseID: course.id!, sequence: topicRequest.sequence, name: topicRequest.name, description: topicRequest.description, hidden: topicRequest.hidden)
                
                return request.transaction(on: .mysql) { conn in
                    return topic.save(on: conn).flatMap { savedTopic in
                        var items: [TopicItem] = []
                        for i in 0..<topicRequest.itemIDs.count {
                            let id = topicRequest.itemIDs[i] != 0 ? topicRequest.itemIDs[i] : nil
                            let problemID = topicRequest.itemProblemIDs[i] != 0 ? topicRequest.itemProblemIDs[i] : nil
                            items.append(TopicItem(id: id, topicID: savedTopic.id!, problemID: problemID, name: topicRequest.itemNames[i], text: topicRequest.itemTexts[i], sequence: i + 1))
                        }
                        return items.map({ $0.save(on: conn) }).flatten(on: conn).flatMap { _ in
                            return request.future(request.redirect(to: "/courses/\(course.id!)"))
                        }
                    }
                }
            }
        }
    }
    
    
    private func save(oldCourse: Course? = nil, delta: CourseRequest, userID: Int, request: Request) -> Future<Response> {
        let newCourse: Course
        if let oldCourse = oldCourse {
            newCourse = oldCourse
            newCourse.code = delta.code
            newCourse.name = delta.name
            newCourse.shortDescription = delta.shortDescription
            newCourse.status = delta.status
            newCourse.languageRestriction = Language(rawValue: delta.languageRestriction)
            newCourse.joinCode = delta.joinCode != nil && delta.joinCode != "" ? delta.joinCode : nil
        }
        else {
            newCourse = Course(code: delta.code, name: delta.name, shortDescription: delta.shortDescription, status: delta.status, userID: userID, languageRestriction: Language(rawValue: delta.languageRestriction), joinCode: delta.joinCode != nil && delta.joinCode != "" ? delta.joinCode : nil)
        }
        
        return newCourse.save(on: request).flatMap { course in
            if oldCourse == nil {
                return CourseMember(courseID: course.id!, userID: userID, role: .admin).save(on: request).flatMap { _ in
                    return request.future(request.redirect(to: "/courses/\(course.id!)"))
                }
            }
            return request.future(request.redirect(to: "/courses/\(course.id!)"))
        }
    }
}

fileprivate struct CourseViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let course: Course
    
    init(course: Course) {
        self.course = course
    }
}

fileprivate struct CourseRequest: Content {
    var code: String
    var name: String
    var shortDescription: String
    var status: PublishStatus
    var languageRestriction: String
    var joinCode: String?
}

fileprivate struct TopicRequest: Content {
    var name: String
    var description: String
    var sequence: Int
    var hidden: Bool
    var itemIDs: [Int]
    var itemNames: [String]
    var itemTexts: [String]
    var itemProblemIDs: [Int]
}
