import FluentMySQL

extension ProblemCase: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.reference(from: \.problemID, to: \Problem.id)
            builder.field(for: \.input, type: .varchar(2000))
            builder.field(for: \.output, type: .varchar(2000))
            builder.field(for: \.visibility, type: .tinyint)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }

}
