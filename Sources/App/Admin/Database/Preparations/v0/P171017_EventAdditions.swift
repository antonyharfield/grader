import Foundation
import FluentProvider

class P171017_EventAdditions: Preparation {
    
    static func prepare(_ database: Database) throws {
        print("P171017_EventAdditions")
        try database.transaction { conn in
            try database.modify(Event.self) { builder in
                builder.string("short_description", length: 1000, default: "")
                builder.int("status", default: 2)
                builder.bool("has_image", default: false)
                builder.int("scoring_system", default: 1)
                builder.int("scores_hidden_before_end", default: 0)
            }
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.transaction { conn in
            try database.modify(Event.self) { builder in
                builder.delete("short_description")
                builder.delete("status")
                builder.delete("has_image")
                builder.delete("scoring_system")
                builder.delete("scores_hidden_before_end")
            }
        }
    }
    
}


