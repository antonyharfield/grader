import FluentMySQL

extension Submission: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.eventProblemID)
            builder.reference(from: \.eventProblemID, to: \EventProblem.id)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.language, type: .varchar(32))
            builder.field(for: \.files)
            builder.field(for: \.state, type: .tinyint)
            builder.field(for: \.score)
            builder.field(for: \.compilerOutput)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }

}
