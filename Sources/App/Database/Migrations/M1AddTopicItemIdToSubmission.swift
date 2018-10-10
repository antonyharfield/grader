import FluentMySQL

class M1AddTopicItemIdToSubmission: Migration {
    typealias Database = MySQLDatabase
    
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.update(Submission.self, on: connection, closure: { builder in
            builder.field(for: \.problemID, type: .int(10, unsigned: true))
            builder.deleteReference(from: \.eventProblemID, to: \EventProblem.id)
            builder.field(for: \.topicItemID, type: .int(10, unsigned: true))
        })
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.update(Submission.self, on: connection, closure: { builder in
            builder.deleteField(for: \.topicItemID)
            builder.reference(from: \.eventProblemID, to: \EventProblem.id)
            builder.deleteField(for: \.problemID)
        })
    }
}
