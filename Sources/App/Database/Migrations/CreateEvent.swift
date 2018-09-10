import FluentMySQL

extension Event: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.name)
            builder.field(for: \.startsAt)
            builder.field(for: \.endsAt)
            builder.field(for: \.languageRestriction, type: .varchar(32))
            builder.field(for: \.shortDescription)
            builder.field(for: \.status, type: .tinyint)
            builder.field(for: \.hasImage)
            builder.field(for: \.scoringSystem, type: .tinyint)
            builder.field(for: \.scoresHiddenBeforeEnd, type: .smallint)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }
}
