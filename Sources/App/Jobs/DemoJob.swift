import Foundation
import Jobs
import Vapor

struct DemoJobData: Codable, JobData {
    let name: String
}

struct DemoJob: Job {
    
    func dequeue(_ context: JobContext, _ data: DemoJobData) -> EventLoopFuture<Void> {
        print("DemoJob: hello \(data.name)")
        return context.eventLoop.future()
    }
    
    func error(_ context: JobContext, _ error: Error, _ data: Data) -> EventLoopFuture<Void> {
        print("DemoJob: error: \(error.localizedDescription)")
        return context.eventLoop.future()
    }
}
