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
                    
                    guard let language = event.languageRestriction
                        ?? Language(rawValue: submissionData.language ?? "") else {
                            throw Abort(.badRequest)
                    }
                    let filename = submissionData.file.filename
                    let fileData = submissionData.file.data
                    
                    // Check the file
                    if fileData.count == 0 {
                        return request.future(request.redirect(to: request.http.urlString).flash(.error, "No file submitted"))
                    }
                    
                    // Create submission first so it has an ID
                    let submission = Submission(problemID: eventProblem.problemID, eventProblemID: eventProblem.id!, userID: user.id!, language: language, files: filename)
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
                            
                            return request.future(request.redirect(to: "/events/\(event.id!)/submissions"))
                        }
                        return request.future(request.redirect(to: "/events/\(event.id!)/problems/\(eventProblem.sequence)").flash(.error, "Unable to save submitted file(s)"))
                    }
                }
            }
            else if let topicItemID = submissionData.topicItemID {
                return try self.processTopicItem(id: topicItemID, request: request).flatMap{ userCourseTopicItem in
                    let courseID = userCourseTopicItem.course.id!
                    let courseTopicSeq = userCourseTopicItem.topic.sequence
                    let topicItemSeq = userCourseTopicItem.topicItem.sequence
                    return request.future(request.redirect(to: "/courses/\(courseID)/topics/\(courseTopicSeq)/\(topicItemSeq)/submissions"))
                }
            }
            else {
                throw Abort(.badRequest)
            }
        }
    }
    
    private func processEventProblem(id: Int, request: Request) throws -> Future<UserEventProblem> {
        let eventProblemFuture = EventProblem.query(on: request)
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
