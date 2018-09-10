import Vapor
import Redis
import Console
import Reswifq

class RedisWorker {
    
    let console: Console
    
    public init(console: Console) {
        self.console = console
    }
    
    func run(on eventLoopWorker: Vapor.Worker) -> Future<Void> {
        let client = RedisClient.connect(on: eventLoopWorker, onError: {_ in })
        
        
        let queue = Reswifq(client: VaporRedisClient(client))
        //queue.jobMap[String(describing: DemoJob.self)] = DemoJob.self
        //queue.jobMap[String(describing: SubmissionJob.self)] = SubmissionJob.self
        
        self.console.print("Starting worker...")
        
        let worker = Worker(queue: queue, maxConcurrentJobs: 4, averagePollingInterval: 0)
        worker.run()
        
        self.console.print("Finished")
        
        return eventLoopWorker.future()
    }
}

