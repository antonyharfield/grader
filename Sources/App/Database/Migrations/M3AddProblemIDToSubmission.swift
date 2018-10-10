import FluentMySQL

class M3AddProblemIdToSubmission: Migration {
    typealias Database = MySQLDatabase
    
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.update(Submission.self, on: connection, closure: { builder in
            builder.reference(from: \.problemID, to: \Problem.id)
        })
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.update(Submission.self, on: connection, closure: { builder in
            builder.deleteReference(from: \.problemID, to: \Problem.id)
        })
    }
}
