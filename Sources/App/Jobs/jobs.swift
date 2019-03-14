import Jobs
import JobsRedisDriver
import Vapor

public func jobs(_ services: inout Services) throws {
    let jobsProvider = JobsProvider(refreshInterval: .seconds(10))
    try services.register(jobsProvider)
    
//    let emailService = EmailService()
//    services.register { _ -> EmailService in
//        return emailService
//    }
    
    services.register { container -> JobContext in
        var jobContext = JobContext(eventLoop: container.eventLoop)
//        jobContext.emailService = emailService
        return jobContext
    }
    
    //Register jobs
    services.register { _ -> JobsConfig in
        var jobsConfig = JobsConfig()
        jobsConfig.add(DemoJob())
        return jobsConfig
    }
    
    services.register { _ -> CommandConfig in
        var commandConfig = CommandConfig.default()
        commandConfig.use(JobsCommand(), as: "jobs")
        return commandConfig
    }
}

//extension JobContext {
//    var emailService: EmailService? {
//        get {
//            return userInfo[String(describing: self)] as? EmailService
//        }
//        set {
//            userInfo[String(describing: self)] = newValue
//        }
//    }
//}
