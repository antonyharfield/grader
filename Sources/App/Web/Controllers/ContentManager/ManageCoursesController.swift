import Vapor
import Leaf
import Authentication
import FluentMySQL

extension ManageCoursesController: RouteCollection {
    func boot(router: Router) throws {
        let teachRouter = router.grouped(SessionAuthenticationMiddleware(), GuardPermissionsMiddleware(.teach))
        teachRouter.post("courses", "add", use: add)
        teachRouter.get("courses", Course.parameter, use: showEdit)
        teachRouter.post("courses", Course.parameter, use: edit)
    }
}

final class ManageCoursesController {
    
    func add(_ request: Request) throws -> Future<View> {
        let leaf = try request.privateContainer.make(LeafRenderer.self)
        return leaf.render("Courses/Teacher/add", request: request)
    }
    
    func showEdit(request: Request) throws -> Future<Response> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            guard course.isEditable(to: user) else {
                throw Abort(.unauthorized)
            }
            
            let context = CourseViewContext(course: course)
            let leaf = try request.make(LeafRenderer.self)
            return try leaf.render("Courses/Teacher/course", context, request: request).encode(for: request)
        }
    }
    
    func edit(_ request: Request) throws -> Future<Response> {
        let courseFuture = try request.parameters.next(Course.self)
        let courseAndUserFuture = courseFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return courseAndUserFuture.flatMap { (course, user) in
            guard course.isEditable(to: user) else {
                throw Abort(.unauthorized)
            }
            
            return try request.content.decode(EditCourseRequest.self).flatMap { editCourseRequest in
                
                let save: () -> (Future<Response>) = {
                    course.code = editCourseRequest.code
                    course.name = editCourseRequest.name
                    course.shortDescription = editCourseRequest.shortDescription
                    course.status = editCourseRequest.status
                    course.languageRestriction = editCourseRequest.languageRestriction
                    course.joinCode = editCourseRequest.joinCode
                    return course.save(on: request).flatMap { _ in
                        return request.future(request.redirect(to: "/courses"))
                    }
                }
                
                if let joinCode = editCourseRequest.joinCode, joinCode != "" {
                    return Course.query(on: request).filter(\.id != course.id).filter(\.joinCode == joinCode).count().flatMap { count in
                        if count > 0 {
                            return request.future(request.redirect(to: "/courses/join").flash(.error, "Join code is not unique"))
                        }
                        return save()
                    }
                }
                
                return save()
            }
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

fileprivate struct EditCourseRequest: Content {
    var code: String
    var name: String
    var shortDescription: String
    var status: PublishStatus
    var languageRestriction: Language?
    var joinCode: String?
}

