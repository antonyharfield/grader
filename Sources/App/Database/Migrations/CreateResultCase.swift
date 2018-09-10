import FluentMySQL

extension ResultCase: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.submissionID)
            builder.reference(from: \.submissionID, to: \Submission.id)
            builder.field(for: \.problemCaseID)
            builder.reference(from: \.problemCaseID, to: \ProblemCase.id)
            builder.field(for: \.output, type: .varchar(2000))
            builder.field(for: \.pass)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }

}
