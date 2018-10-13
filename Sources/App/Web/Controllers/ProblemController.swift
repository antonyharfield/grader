import Vapor
//import Reswifq
import Leaf
import FluentMySQL

extension ProblemController: RouteCollection {
    func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.post("problems", Problem.parameter, use: submit)
    }
}

final class ProblemController {

    func submit(request: Request) throws -> Future<Response> {
        let problemFuture = try request.parameters.next(Problem.self)
        let submissionDataFuture = try request.content.decode(SubmissionData.self)
        return problemFuture.and(submissionDataFuture).flatMap { (problem, submissionData) in
            
            if let eventProblemID = submissionData.eventProblemID {
                return try self.processEventProblem(id: eventProblemID, request: request).flatMap { ueep in
                    let user = ueep.user
                    let event = ueep.event
                    let eventProblem = ueep.eventProblem
                    let redirect = "/events/\(event.id!)/problems/\(eventProblem.sequence)"
                    
                    return try self.saveSubmission(data: submissionData, problemID: eventProblem.problemID, languageRestriction: event.languageRestriction, user: user, redirect: redirect, on: request)
                }
            }
            else if let topicItemID = submissionData.topicItemID {
                return try self.processTopicItem(id: topicItemID, request: request).flatMap{ userCourseTopicItem in
                    let user = userCourseTopicItem.user
                    let course = userCourseTopicItem.course
                    let courseTopicSeq = userCourseTopicItem.topic.sequence
                    let topicItemSeq = userCourseTopicItem.topicItem.sequence
                    let redirect = "/courses/\(course.id!)/topics/\(courseTopicSeq)/\(topicItemSeq)"
                    
                    guard let problemID = userCourseTopicItem.topicItem.problemID else {
                        throw Abort(.badRequest)
                    }
                    return try self.saveSubmission(data: submissionData, problemID: problemID, languageRestriction: course.languageRestriction, user: user, redirect: redirect, on: request)
                }
            }
            else {
                throw Abort(.badRequest)
            }
        }
    }
    
    private func processEventProblem(id: Int, request: Request) throws -> Future<UserEventProblem> {
        let eventProblemFuture = EventProblem.query(on: request).filter(\.id == id)
                .join(\Event.id, to: \EventProblem.eventID).alsoDecode(Event.self).first().unwrap(or: Abort(.internalServerError))
        
        let eventProblemAndUserFuture = eventProblemFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return eventProblemAndUserFuture.flatMap { (eventProblemAndEvent, user) in
            guard eventProblemAndEvent.1.isVisible(to: user) else {
                throw Abort(.unauthorized)
            }
            return request.future(UserEventProblem(user: user, event: eventProblemAndEvent.1, eventProblem: eventProblemAndEvent.0))
        }
    }
    
    private func processTopicItem(id: Int, request: Request) throws -> Future<UserTopicItem> {
        let topicItemFuture = TopicItem.query(on: request).filter(\.id == id)
            .join(\Topic.id, to: \TopicItem.topicID).alsoDecode(Topic.self)
            .join(\Course.id, to: \Topic.courseID).alsoDecode(Course.self)
            .first().unwrap(or: Abort(.internalServerError))
        
        let topicItemAndUserFuture = topicItemFuture.and(request.sessionUser().unwrap(or: Abort(.internalServerError)))
        
        return topicItemAndUserFuture.flatMap { (topicItemAndTopicAndCourse, user) in
            // TODO check user has permission
            return request.future(UserTopicItem(user: user, course: topicItemAndTopicAndCourse.1, topic: topicItemAndTopicAndCourse.0.1, topicItem: topicItemAndTopicAndCourse.0.0))
        }
    }
    
    private func saveSubmission(data: SubmissionData, problemID: Int, languageRestriction: Language?, user: User, redirect: String, on request: Request) throws -> Future<Response> {
        guard let language = languageRestriction ?? Language(rawValue: data.language ?? "") else {
            throw Abort(.badRequest)
        }
        let filename = data.file.filename
        let fileData = data.file.data
        
        // Check the file
        if fileData.count == 0 {
            return request.future(request.redirect(to: request.http.urlString).flash(.error, "No file submitted"))
        }
        
        // Create submission first so it has an ID
        let submission: Submission
        if let eventProblemID = data.eventProblemID {
            submission = Submission(problemID: problemID, eventProblemID: eventProblemID, userID: user.id!, language: language, files: filename)
        }
        else if let topicItemID = data.topicItemID {
            submission = Submission(problemID: problemID, topicItemID: topicItemID, userID: user.id!, language: language, files: filename)
        }
        else {
            throw Abort(.badRequest)
        }
        return submission.save(on: request).flatMap { submission in
            
            // Save the files
            let fileSystem = FileSystem()
            let uploadPath = fileSystem.submissionUploadPath(submission: submission)
            fileSystem.ensurePathExists(at: uploadPath)
            let success = fileSystem.save(data: fileData, path: uploadPath + filename)
            
            if success {
                // Queue job
                // TODO: don't fail if we cannot connect to the queue!
                //let job = SubmissionJob(submissionID: submission.id!.int!)
                //try Reswifq.defaultQueue.enqueue(job)
                
                return request.future(request.redirect(to: redirect))
            }
            return request.future(request.redirect(to: redirect).flash(.error, "Unable to save submitted file(s)"))
        }
    }

}

fileprivate struct UserEventProblem {
    let user: User
    let event: Event
    let eventProblem: EventProblem
}

fileprivate struct UserTopicItem {
    let user: User
    let course: Course
    let topic: Topic
    let topicItem: TopicItem
}
