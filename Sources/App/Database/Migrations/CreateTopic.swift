import FluentMySQL

extension Topic: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.courseID)
            builder.field(for: \.sequence)
            builder.field(for: \.name)
            builder.field(for: \.description)
            builder.field(for: \.hidden)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.delete(self, on: connection)
    }
}
