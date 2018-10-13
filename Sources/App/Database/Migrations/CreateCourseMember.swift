import FluentMySQL

extension CourseMember: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.courseID)
            builder.reference(from: \.courseID, to: \Course.id)
            builder.field(for: \.userID, type: .int(10, unsigned: true))
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.role)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }
}
