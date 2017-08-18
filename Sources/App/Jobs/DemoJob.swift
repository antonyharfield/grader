import Foundation
import Reswifq

public struct DemoJob: Job {
    
    // MARK: Initialization
    public init() {
        self.identifier = UUID().uuidString
    }
    
    // MARK: Attributes
    public let identifier: String
    
    // MARK: Job
    public func perform() throws {
        let problem = Problem(name: identifier, description: "Swift", order: 9999)
        try problem.save()
    }
    
    // MARK: DataDecodable
    public init(data: Data) throws {
        
        let object = try JSONSerialization.jsonObject(with: data)
        
        guard let dictionary = object as? Dictionary<String, Any> else {
            throw DataDecodableError.invalidData(data)
        }
        
        guard let identifier = dictionary["identifier"] as? String else {
            throw DataDecodableError.invalidData(data)
        }
        
        self.identifier = identifier
    }
    
    // MARK: DataEncodable
    public func data() throws -> Data {
        
        let object: [String: Any] = [
            "identifier": self.identifier
        ]
        
        return try JSONSerialization.data(withJSONObject: object)
    }
}
