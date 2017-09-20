import Vapor
import AuthProvider

public final class UsersController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /**
     * Logout, will logout auther user and redirect back to login
     *
     * - param: Request
     * - return: Response
     */
    public func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.unauthenticate()
        return Response(redirect: "/").flash(.error, "User is logged out")
    }
    
//    /**
//     * List all backend users
//     *
//     * - param: Request
//     * - return: View
//     */
//    public func index(request: Request) throws -> ResponseRepresentable {
//        try Gate.allowOrFail(request, "admin")
//        
//        let query = try BackendUser.query()
//        if let search: String = request.query?["search"]?.string {
//            try query.filter("name", contains: search)
//        }
//        let users = try query.paginator(25, request: request)
//        
//        // Search
//        return try drop.view.make("BackendUsers/index", [
//            "users": try users.makeNode()
//            ], for: request)
//    }
//    
//    /**
//     * Create user form
//     *
//     * - param: Request
//     * - return: View
//     */
//    public func create(request: Request) throws -> ResponseRepresentable {
//        try Gate.allowOrFail(request, "admin")
//        
//        return try drop.view.make("BackendUsers/edit", [
//            "fieldset": BackendUserForm.getFieldset(request),
//            "roles": Configuration.shared?.getRoleOptions(request.authedBackendUser().role).makeNode() ?? [:],
//            "defaultRole": (Configuration.shared?.defaultRole ?? "user").makeNode()
//            ], for: request)
//    }
//    
//    /**
//     * Save new user
//     *
//     * - param: Request
//     * - return: View
//     */
//    public func store(request: Request) throws -> ResponseRepresentable {
//        try Gate.allowOrFail(request, "admin")
//        
//        do {
//            // Validate
//            let backendUserForm = try BackendUserForm(validating: request.data)
//            
//            // Store
//            var backendUser = try BackendUser(form: backendUserForm, request: request)
//            try backendUser.save()
//            
//            // Send welcome mail
//            if backendUserForm.sendMail {
//                let mailPw: String? = backendUserForm.randomPassword ? backendUserForm.password : nil
//                try Mailer.sendWelcomeMail(drop: drop, backendUser: backendUser, password: mailPw)
//            }
//            
//            return Response(redirect: "/admin/backend_users").flash(.success, "User created")
//        }catch FormError.validationFailed(let fieldSet) {
//            return Response(redirect: "/admin/backend_users/create").flash(.error, "Validation error").withFieldset(fieldSet)
//        }catch {
//            return Response(redirect: "/admin/backend_users/create").flash(.error, "Failed to create user")
//        }
//    }
//    
//    /**
//     * Edit user form
//     *
//     * - param: Request
//     * - param: BackendUser
//     * - return: View
//     */
//    public func edit(request: Request, backendUser: BackendUser) throws -> ResponseRepresentable {
//        if try  backendUser.id != request.auth.user().id {
//            try Gate.allowOrFail(request, "admin")
//            try Gate.allowOrFail(request, backendUser.role)
//        }
//        
//        return try drop.view.make("BackendUsers/edit", [
//            "fieldset": BackendUserForm.getFieldset(request),
//            "backendUser": try backendUser.makeNode(),
//            "roles": Configuration.shared?.getRoleOptions(request.authedBackendUser().role).makeNode() ?? [:],
//            "defaultRole": (Configuration.shared?.defaultRole ?? "user").makeNode()
//            ], for: request)
//    }
//    
//    /**
//     * Update user
//     *
//     * - param: Request
//     * - param: BackendUser
//     * - return: View
//     */
//    public func update(request: Request) throws -> ResponseRepresentable {
//        guard let id = request.data["id"]?.int, var backendUser = try BackendUser.query().filter("id", id).first() else {
//            throw Abort.notFound
//        }
//        
//        
//        if try  backendUser.id != request.auth.user().id {
//            try Gate.allowOrFail(request, "admin")
//            try Gate.allowOrFail(request, backendUser.role)
//        }
//        
//        do {
//            // Validate
//            let backendUserForm = try BackendUserForm(validating: request.data)
//            
//            // Store
//            try backendUser.fill(form: backendUserForm, request: request)
//            try backendUser.save()
//            
//            if Gate.allow(request, "admin") {
//                return Response(redirect: "/admin/backend_users").flash(.success, "User updated")
//            } else {
//                return Response(redirect: "/admin/backend_users/edit/" + String(id)).flash(.success, "User updated")
//            }
//            
//        }catch FormError.validationFailed(let fieldSet) {
//            return Response(redirect: "/admin/backend_users/edit/" + String(id)).flash(.error, "Validation error").withFieldset(fieldSet)
//        }catch {
//            return Response(redirect: "/admin/backend_users/edit/" + String(id)).flash(.error, "Failed to update user")
//        }
//    }
//    
//    /**
//     * Delete user
//     *
//     * - param: Request
//     * - param: BackendUser
//     * - return: View
//     */
//    public func destroy(request: Request, backendUser: BackendUser) throws -> ResponseRepresentable {
//        try Gate.allowOrFail(request, "admin")
//        try Gate.allowOrFail(request, backendUser.role)
//        do {
//            try backendUser.delete()
//            return Response(redirect: "/admin/backend_users").flash(.success, "Deleted user")
//        } catch {
//            return Response(redirect: "/admin/backend_users").flash(.error, "Failed to delete user")
//        }
//    }
//    
}
