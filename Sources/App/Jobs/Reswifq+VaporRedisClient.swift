import Reswifq
import Redis
import VaporRedisClient

extension Reswifq {
    
    static var defaultQueue: Reswifq {
        let client = VaporRedisClient(try! TCPClient(hostname: "redis", port: 6379))
        return Reswifq(client: client)
    }
    
}
