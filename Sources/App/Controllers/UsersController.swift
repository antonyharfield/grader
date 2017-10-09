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
        return try render("users", ["users": users], for: request, with: view)
    }
    
    //Edit
    func editForm(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        let user = try User.find(userID)
        return try view.make("edit-user", ["editUser": user])
    }
    
    func edit(request: Request) throws -> ResponseRepresentable {
        guard let name =  request.data["name"]?.string,
            let username =  request.data["username"]?.string,
            let imageUser = request.formData?["image"],
            let password =  request.data["password"]?.string else {
                throw Abort.badRequest
                
        }
        
        // get the Post model and save to DB
        let userID = try request.parameters.next(Int.self)
        if let user = try User.find(userID){
            user.name = name
            user.username = username
            if password != "" {
                user.setPassword(password)
            }
            try user.save()
            
            let path = "/Users/student/Documents/Thesis-garder/grader/Public/uploads/\(user.id!.string!).jpg"
            _ = save(bytes: imageUser.bytes!, path: path)
        }
        
        return Response(redirect: "/users")
        
    }
    
    //Delete
    func deleteForm(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        let user = try User.find(userID)
        return try view.make("delete-user", ["deleteUser": user])
    }
    
    func delete(request: Request) throws -> ResponseRepresentable {
        
        let userID = try request.parameters.next(Int.self)
        if let user = try User.find(userID){
            try user.delete()
        }
        
        return Response(redirect: "/users")
    }
    

}
