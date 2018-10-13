import FluentMySQL

extension Course: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.code)
            builder.field(for: \.name)
            builder.field(for: \.shortDescription)
            builder.field(for: \.userID)
            builder.field(for: \.languageRestriction)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }
}
