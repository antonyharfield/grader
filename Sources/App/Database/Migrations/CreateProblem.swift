import FluentMySQL

extension Problem: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.description)
            builder.field(for: \.comparisonMethod, type: .varchar(16))
            builder.field(for: \.comparisonIgnoresSpaces)
            builder.field(for: \.comparisonIgnoresBreaks)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }
    
}
