import Vapor
import AuthProvider

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
        
        // TODO: implement csv parsing
        
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

}
