import Foundation
import FluentProvider

class P170924_ProblemCaseVisibility: Preparation {
    
    static func prepare(_ database: Database) throws {
        print("Anyone there?")
        try database.transaction { conn in
            // Add new
            try database.modify(ProblemCase.self) { builder in
                builder.int("visibility", default: 1)
            }
            
            // Migrate data
            try database.raw("UPDATE problem_cases SET visibility = CASE WHEN visible THEN 1 ELSE 2 END")
            
            // Remove obsolete
            if !(database.driver is Fluent.SQLiteDriver) {
                try database.modify(ProblemCase.self) { builder in
                    builder.delete("visible")
                }
            }
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.transaction { conn in
            // Restore obsolete
            try database.modify(ProblemCase.self) { builder in
                builder.bool("visible", default: 1)
            }
            
            // Migrate data
            try database.raw("UPDATE problem_cases SET visible = CASE WHEN visibility = 1 THEN 1 ELSE 0 END")
            
            // Remove new
            try database.modify(ProblemCase.self) { builder in
                builder.delete("visibility")
            }
        }
    }
    
}
