import FluentMySQL

extension EventProblem: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.eventID)
            builder.reference(from: \.eventID, to: \Event.id)
            builder.field(for: \.problemID)
            builder.reference(from: \.problemID, to: \Problem.id)
            builder.field(for: \.sequence)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }

}
