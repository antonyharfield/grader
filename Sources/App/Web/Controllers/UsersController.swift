import Vapor
import AuthProvider

public final class UsersController {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    //Show User
    func showUser(request: Request) throws -> ResponseRepresentable {

        let users = try User.all()
        return try render("Users/users", ["users": users], for: request, with: view)
    }

    //Edit
    func editForm(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        let user = try User.find(userID)
        return try render("Users/edit-user", ["user": user], for: request, with: view)
    }

    func edit(request: Request) throws -> ResponseRepresentable {
        guard let name =  request.data["name"]?.string,
            let username =  request.data["username"]?.string else {
                throw Abort.badRequest
        }

        let image = request.formData?["image"]
        let newPassword =  request.data["password"]?.string
        
        let userID = try request.parameters.next(Int.self)
        if let user = try User.find(userID){
            user.name = name
            user.username = username
            if let password = newPassword, password != "" {
                user.setPassword(password)
            }
            try user.save()

            if let image = image {
                let path = "/Users/student/Documents/Thesis-garder/grader/Public/uploads/\(user.id!.string!).jpg"
                _ = save(bytes: imageUser.bytes!, path: path)
            }
        }

        return Response(redirect: "/users")
    }

    //Delete
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
