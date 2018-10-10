import FluentMySQL

class M2AddProblemIdToSubmission: Migration {
    typealias Database = MySQLDatabase


    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection.raw("update submissions s set problemID = (select ep.problemID from event_problems ep where ep.id = s.eventProblemID)").run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection.future()
    }
}
