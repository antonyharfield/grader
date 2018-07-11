import FluentMySQL

extension Event: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.name)
            builder.field(for: \.startsAt)
            builder.field(for: \.endsAt)
            builder.field(for: \.languageRestriction)
            builder.field(for: \.shortDescription)
            builder.field(for: \.status)
            builder.field(for: \.hasImage)
            builder.field(for: \.scoringSystem)
            builder.field(for: \.scoresHiddenBeforeEnd)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }
}
