import FluentMySQL

public func migrate(_ migrations: inout MigrationConfig) throws {
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Event.self, database: .mysql)
    migrations.add(model: Problem.self, database: .mysql)
    migrations.add(model: EventProblem.self, database: .mysql)
    migrations.add(model: ProblemCase.self, database: .mysql)
    migrations.add(model: Submission.self, database: .mysql)
    migrations.add(model: ResultCase.self, database: .mysql)
}
