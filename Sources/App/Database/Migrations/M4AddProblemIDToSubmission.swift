import FluentMySQL

class M4AddProblemIdToSubmission: Migration {
    typealias Database = MySQLDatabase


    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection.raw("ALTER TABLE submissions MODIFY eventProblemID INT(10) unsigned").run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection.future()
    }
}
