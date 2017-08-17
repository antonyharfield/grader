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
            
            //            var tcpClient: TCPClient?
            //            print("Try to get a client")
            //            while tcpClient == nil {
            //                do {
            //                    tcpClient = try TCPClient(hostname: "redis", port: 6379)
            //                }
            //                catch {
            //                    print("Unable to connect, sleeping")
            //                    //sleep(3)
            //                }
            //            }
            //            print("Got a client")
            //            return VaporRedisClient(tcpClient!)
            self.console.print("Create client")
            return VaporRedisClient(try! TCPClient(hostname: "redis", port: 6379))
        }
        
        let queue = Reswifq(client: client)
        queue.jobMap[String(describing: DemoJob.self)] = DemoJob.self
        
        console.print("Starting worker...")

        let worker = Worker(queue: queue, maxConcurrentJobs: 4, averagePollingInterval: 0)
        worker.run()
        
        console.print("Finished")
    }
    
}
