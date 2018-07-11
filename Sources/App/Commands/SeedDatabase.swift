import Vapor
import Console

final class SeedCommand: Command {
    
    var arguments: [CommandArgument] {
        return []
    }
    
    var options: [CommandOption] {
        return []
    }
    
    var help: [String] {
        return ["Seed the database."]
    }
    
    func run(using context: CommandContext) throws -> Future<Void> {
        context.console.print("Seeding database")
        let seeder = DefaultSeeder()
        try seeder.deleteAll()
        try seeder.insertUsers()
        try seeder.insertProblems()
        try seeder.insertEvents()
        context.console.print("Database seed complete")
        return .done(on: context.container)
    }
    
}
