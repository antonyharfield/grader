import RedisClient
import Reswifq
import struct Redis.RedisData

extension VaporRedisClient: RedisClient {
    
    public func execute(_ command: String, arguments: [String]?) throws -> RedisClientResponse {
        
        let client = try self.client.wait()
        let redisArguments = (arguments ?? []).map({ RedisData.basicString($0) })
        let response = try client.command(command, redisArguments).wait()
        
        return RedisClientResponse(response: response)
    }
}

extension RedisClientResponse {
    
    init(response: RedisData) {

        if response.isNull {
            self = .null
        }
        else if let string = response.string {
            self = .string(string)
        }
        else if let int = response.int {
            self = .integer(Int64(int))
        }
        else if let array = response.array {
            self = .array(array.map { RedisClientResponse(response: $0) })
        }
        else {
            self = .error("Error from RedisData")
        }
    }
}
