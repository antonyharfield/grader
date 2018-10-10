import FluentMySQL

extension TopicItem: Migration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.topicID)
            builder.reference(from: \.topicID, to: \Topic.id)
            builder.field(for: \.problemID)
            builder.field(for: \.name)
            builder.field(for: \.text, type: .varchar(4000))
            builder.field(for: \.sequence)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }

}

//
