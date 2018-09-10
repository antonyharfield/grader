import Foundation
import Redis

class VaporRedisClient {
    
    required init(_ client: Future<RedisClient>) {
        self.client = client
    }
    
    public let client: Future<RedisClient>
}

