import FluentMySQL

extension CourseTopic: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.topicID)
            builder.reference(from: \.topicID, to: \Topic.id)
            builder.field(for: \.courseID)
            builder.reference(from: \.courseID, to: \Course.id)
            builder.field(for: \.sequence)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }
}
