import Foundation
import VaporRedisClient
import Redis
import RedisClient
import Reswifq
import App

print("Starting...")

let client = RedisClientPool(maxElementCount: 10) { () -> RedisClient in
    
    var tcpClient: TCPClient?
    print("Try to get a client")
    while tcpClient == nil {
        do {
            tcpClient = try TCPClient(hostname: "redis", port: 6379)
        }
        catch {
            print("Unable to connect, sleeping")
            //sleep(3)
        }
    }
    print("Got a client")
    return VaporRedisClient(tcpClient!)
    
    //return VaporRedisClient(try! TCPClient(hostname: "redis", port: 6379))
}

let queue = Reswifq(client: client)
queue.jobMap[String(describing: DemoJob.self)] = DemoJob.self

let worker = Worker(queue: queue, maxConcurrentJobs: 4, averagePollingInterval: 0)

print("Running worker...")

worker.run()

print("Finished")
