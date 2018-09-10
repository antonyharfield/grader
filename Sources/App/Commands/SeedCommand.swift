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
        
        guard let container = context.container as? DatabaseConnectable else {
            return .done(on: context.container)
        }
        context.console.print("Seeding database")
        
        let seeder = DefaultSeeder(on: container)
        try seeder.deleteAll()
        try seeder.insertUsers()
        try seeder.insertProblems()
        try seeder.insertEvents()
        context.console.print("Database seed complete")
        return .done(on: context.container)
    }
    
}
