import Vapor
import FluentMySQL

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    
    /// Test the connection to the database
    app.withPooledConnection(to: .mysql) { conn in
        return conn.query("select @@version as v;").map(to: String.self) { rows in
            return try rows[0].firstValue(forColumn: "v")?.decode(String.self) ?? "n/a"
        }
        }.whenSuccess { result in
            print("Running MySQL version \(result)")
        }
}
