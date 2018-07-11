import Vapor
import Authentication
import Leaf

extension ProfileController: RouteCollection {
    public func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("profile", use: profile)
        authedRouter.get("logout", use: logout)
    }
}

public final class ProfileController {

    func logout(_ request: Request) throws -> Response {
        try request.sessionLogout()
        return request.redirect(to: "/").flash(.error, "User is logged out")
    }

    func profile(_ request: Request) throws -> Future<View> {
        return try request.requireSessionUser().flatMap { user in
            let leaf = try request.make(LeafRenderer.self)
            return leaf.render("Users/profile", ProfileViewContext(user: user), request: request)
        }
    }
    
//    func image(request: Request) throws -> ResponseRepresentable {
//        let user = request.user!
//        if !user.hasImage {
//            return try Response(filePath: "Public/images/profile-placeholder.png")
//        }
//        let fileSystem = FileSystem()
//        return try Response(filePath: fileSystem.userProfileImagePath(user: user))
//    }
//
//    func editForm(request: Request) throws -> ResponseRepresentable {
//        let user = request.user!
//        return try render("Users/edit-user", ["user": user], for: request, with: view)
//    }
//
//    func edit(request: Request) throws -> ResponseRepresentable {
//        guard let name = request.data["name"]?.string,
//            let username = request.data["username"]?.string else {
//                throw Abort.badRequest
//        }
//
//        let user = request.user!
//        user.name = name
//        user.username = username
//
//        // If the user selected a new profile image
//        if let profileImageData = request.formData?["image"], let bytes = profileImageData.bytes,
//            let mimeType = profileImageData.part.headers["Content-Type"] {
//            if mimeType != "image/jpeg" {
//                return Response(redirect: "/profile/edit").flash(.error, "Image should be jpeg files only (.jpg)")
//            }
//            let fileSystem = FileSystem()
//            fileSystem.ensurePathExists(path: fileSystem.userFilesPath(user: user))
//            let uploadPath = fileSystem.userProfileImagePath(user: user)
//            if !fileSystem.save(bytes: bytes, path: uploadPath) {
//                return Response(redirect: "/profile/edit").flash(.error, "Unable to save the file")
//            }
//            user.hasImage = true
//        }
//
//        try user.save()
//
//        return Response(redirect: "/profile")
//    }
//
//    func changePasswordForm(request: Request) throws -> ResponseRepresentable {
//        return try render("Users/change-password", [:], for: request, with: view)
//    }
//
//    func changePassword(request: Request) throws -> ResponseRepresentable {
//        guard let oldPassword = request.data["oldpassword"]?.string, let newPassword = request.data["newpassword"]?.string,
//            let confirmPassword = request.data["confirmpassword"]?.string else {
//            throw Abort.badRequest
//        }
//
//        let user = request.user!
//
//        guard let verifier = User.passwordVerifier, let oldHashedPassword = user.hashedPassword, let oldPasswordMatches = try? verifier.verify(password: oldPassword.makeBytes(), matches: oldHashedPassword.makeBytes()) else {
//            throw Abort.serverError
//        }
//        if !oldPasswordMatches {
//            return Response(redirect: "/changepassword").flash(.error, "Incorrect existing password")
//        }
//
//        if !User.passwordMeetsRequirements(newPassword) {
//            return Response(redirect: "/changepassword").flash(.error, "Password does not meet requirements (4 or more characters)")
//        }
//
//        if newPassword != confirmPassword {
//            return Response(redirect: "/changepassword").flash(.error, "New password does not match confirmed password")
//        }
//        user.setPassword(newPassword)
//        try user.save()
//
//        return Response(redirect: "/profile")
//    }
}

//fileprivate struct ProfileViewContext: ViewContext {
//    let user: User
//    var common: CommonViewContext? = nil
//
//    init(user: User) {
//        self.user = user
//    }
//}

fileprivate struct ProfileViewContext: ViewContext {
    var common: CommonViewContext?
    let user: User
    init(user: User) {
        self.user = user
    }
}
