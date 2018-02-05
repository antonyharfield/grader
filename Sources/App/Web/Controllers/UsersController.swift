import Vapor
import AuthProvider
import Fluent

public final class UsersController {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    func showUser(request: Request) throws -> ResponseRepresentable {
        let users = try User.all()
        return try render("Users/users", ["users": users], for: request, with: view)
    }
    
    func image(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(User.self)
        if !user.hasImage {
            return try Response(filePath: "Public/images/profile-placeholder.png")
        }
        let fileSystem = FileSystem()
        return try Response(filePath: fileSystem.userProfileImagePath(user: user))
    }
    
    func addForm(request: Request) throws -> ResponseRepresentable {
        return try render("Users/add-users", for: request, with: view)
    }
    
    func add(request: Request) throws -> ResponseRepresentable {
        guard let data = request.data["users_raw"]?.string else {
            throw Abort.badRequest
        }
        
        var newUsers = [User]()
        
        // Parse the data
        let cleanedData = data.replacingOccurrences(of: "\r", with: "\n", options: .regularExpression)
        for line in cleanedData.components(separatedBy: "\n") {
            let fields = line.components(separatedBy: "\t")

            // Skip empty lines
            if fields.count <= 1 {
                continue
            }

            // Error if not 4 fields
            if fields.count != 4 {
                return Response(redirect: "/users/new").flash(.error, "Each line must contain only 4 fields (tab-separated)")
            }

            let user = User(name: fields[0], email: fields[1], username: fields[2], password: fields[3], role: .student)
            newUsers.append(user)
        }
        
        // Perform saves in a transaction
        do {
            try User.database!.transaction { conn in
                for user in newUsers {
                    try user.save()
                }
            }
        }
        catch let error as TransactionError {
            return Response(redirect: "/users/new").flash(.error, "Error saving to the database: \(error.reason)")
        }
        
        return Response(redirect: "/users")
    }


    func editForm(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        let user = try User.find(userID)
        return try render("Users/edit-user", ["user": user], for: request, with: view)
    }

    func edit(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["name"]?.string,
            let username = request.data["username"]?.string,
            let email = request.data["email"]?.string else {
                throw Abort.badRequest
        }

        let newPassword = request.data["password"]?.string
        
        let userID = try request.parameters.next(Int.self)
        if let user = try User.find(userID){
            user.name = name
            user.email = email
            user.username = username
            if let password = newPassword, password != "" {
                user.setPassword(password)
            }
            try user.save()
        }

        return Response(redirect: "/users")
    }

    func deleteForm(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        let user = try User.find(userID)
        return try render("Users/delete-user", ["user": user], for: request, with: view)
    }

    func delete(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        if let user = try User.find(userID){
            try user.delete()
        }

        return Response(redirect: "/users")
    }

    func bulkPasswordSetForm(request: Request) throws -> ResponseRepresentable {
        return try render("Users/bulk-password", for: request, with: view)
    }
    
    func bulkPasswordSet(request: Request) throws -> ResponseRepresentable {
        guard let data = request.data["users_raw"]?.string else {
            throw Abort.badRequest
        }
        
        var idsAndPasswords = [(String,String)]()
        
        // Parse the data
        let cleanedData = data.replacingOccurrences(of: "\r", with: "\n", options: .regularExpression)
        for line in cleanedData.components(separatedBy: "\n") {
            let fields = line.components(separatedBy: "\t")
            
            // Skip empty lines
            if fields.count <= 1 {
                continue
            }
            
            // Error if not 2 fields
            if fields.count != 2 {
                return Response(redirect: "/users/new").flash(.error, "Each line must contain only 2 fields (tab-separated)")
            }
            
            idsAndPasswords.append((fields[0], fields[1]))
        }
        
        // Perform saves in a transaction
        do {
            try User.database!.transaction { conn in
                for (id, password) in idsAndPasswords {
                    if let user = try User.makeQuery().filter("username", id).first() {
                        user.setPassword(password)
                        try user.save()
                    }
                }
            }
        }
        catch let error as TransactionError {
            return Response(redirect: "/users/new").flash(.error, "Error saving to the database: \(error.reason)")
        }
        
        return Response(redirect: "/users")
    }

}
