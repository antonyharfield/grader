import VaporRedisClient
import Redis
import RedisClient
import Reswifq
import Console

class RedisWorker {
    
    let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    func run() {
        console.print("Preparing redis client pool...")
        
        let client = RedisClientPool(maxElementCount: 10) { () -> RedisClient in
            self.console.print("Create client")
            return VaporRedisClient(try! TCPClient(hostname: "redis", port: 6379))
        }
        
        let queue = Reswifq(client: client)
        queue.jobMap[String(describing: DemoJob.self)] = DemoJob.self
        queue.jobMap[String(describing: SubmissionJob.self)] = SubmissionJob.self
        
        console.print("Starting worker...")

        let worker = Worker(queue: queue, maxConcurrentJobs: 4, averagePollingInterval: 0)
        worker.run()
        
        console.print("Finished")
    }
    
}
