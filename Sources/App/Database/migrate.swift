import FluentMySQL

public func migrate(_ migrations: inout MigrationConfig) throws {
    // Original
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Event.self, database: .mysql)
    migrations.add(model: Problem.self, database: .mysql)
    migrations.add(model: EventProblem.self, database: .mysql)
    migrations.add(model: ProblemCase.self, database: .mysql)
    migrations.add(model: Submission.self, database: .mysql)
    migrations.add(model: ResultCase.self, database: .mysql)
    // Migrate to Vapor 3
    migrations.add(model: Achievement.self, database: .mysql)
    migrations.add(model: AchievementUser.self, database: .mysql)
    migrations.add(model: Course.self, database: .mysql)
    migrations.add(model: CourseMember.self, database: .mysql)
    migrations.add(model: Topic.self, database: .mysql)
    migrations.add(model: TopicItem.self, database: .mysql)
    migrations.add(migration: M1AddTopicItemIdToSubmission.self, database: .mysql)
    migrations.add(migration: M2AddProblemIdToSubmission.self, database: .mysql)
    migrations.add(migration: M3AddProblemIdToSubmission.self, database: .mysql)
}
