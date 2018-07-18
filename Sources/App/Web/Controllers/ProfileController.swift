import Vapor
import Authentication
import Leaf

extension ProfileController: RouteCollection {
    public func boot(router: Router) throws {
        let authedRouter = router.grouped(SessionAuthenticationMiddleware())
        authedRouter.get("logout", use: logout)
        authedRouter.get("profile", use: profile)
        authedRouter.get("profile/image", use: image)
        authedRouter.get("profile/edit", use: editForm)
        authedRouter.post("profile/edit", use: edit)
        authedRouter.get("changepassword", use: changePasswordForm)
        authedRouter.post("changepassword", use: changePassword)
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
    
    func image(request: Request) throws -> Future<Response> {
        return try request.requireSessionUser().flatMap { user in
            let fileSystem = FileSystem()
            let imagePath = fileSystem.userProfileImagePath(user: user)
            guard user.hasImage, fileSystem.fileExists(at: imagePath) else {
                return try request.streamFile(at: "Public/images/profile-placeholder.png")
            }
            return try request.streamFile(at: imagePath)
        }
    }

    func editForm(request: Request) throws -> Future<View> {
        return try request.requireSessionUser().flatMap { user in
            let leaf = try request.privateContainer.make(LeafRenderer.self)
            return leaf.render("Users/edit-user", ProfileViewContext(user: user), request: request)
        }
    }

    func edit(request: Request) throws -> Future<Response> {
        
        let userBefore = try request.requireSessionUser()
        let userDelta = try request.content.decode(UserData.self)
        
        return userDelta.and(userBefore).flatMap(to: Response.self) { userDelta, user in
            
            user.name = userDelta.name
            user.username = userDelta.username
        
            if let image = userDelta.image, let contentType = image.contentType {
                if contentType.description != "image/jpeg" {
                    return request.future(request.redirect(to: "/profile/edit").flash(.error, "Image should be jpeg files only (.jpg)"))
                }
                let fileSystem = FileSystem()
                fileSystem.ensurePathExists(at: fileSystem.userFilesPath(user: user))
                let uploadPath = fileSystem.userProfileImagePath(user: user)
                if !fileSystem.save(data: image.data, path: uploadPath) {
                    return request.future(request.redirect(to: "/profile/edit").flash(.error, "Unable to save the file"))
                }
                user.hasImage = true
            }

            return user.update(on: request).map { newUser in
                guard user.id == newUser.id else {
                    throw Abort(.internalServerError)
                }
                return request.redirect(to: "/profile")
            }
        }
    }
    
    func changePasswordForm(request: Request) throws -> Future<View> {
        return try request.requireSessionUser().flatMap { user in
            let leaf = try request.privateContainer.make(LeafRenderer.self)
            return leaf.render("Users/change-password", NoContextCommonViewContext(), request: request)
        }
    }

    func changePassword(request: Request) throws -> Future<Response> {
        let userBefore = try request.requireSessionUser()
        let passwordData = try request.content.decode(ChangePasswordData.self)
        
        return userBefore.and(passwordData).flatMap(to: Response.self) { user, passwordData in
            
            let verifier = try request.make(BCryptDigest.self)
            guard try verifier.verify(passwordData.currentPassword, created: user.password) else {
                return request.future(request.redirect(to: "/changepassword").flash(.error, "Incorrect existing password"))
            }
            
            if !User.passwordMeetsRequirements(passwordData.newPassword) {
                return request.future(request.redirect(to: "/changepassword").flash(.error, "Password does not meet requirements (4 or more characters)"))
            }
            
            if passwordData.newPassword != passwordData.confirmNewPassword {
                return request.future(request.redirect(to: "/changepassword").flash(.error, "New password does not match confirmed password"))
            }
            
            user.password = try verifier.hash(passwordData.newPassword)
            
            return user.update(on: request).map { newUser in
                guard user.id == newUser.id else {
                    throw Abort(.internalServerError)
                }
                return request.redirect(to: "/profile")
            }
        }
    }
}

fileprivate struct ProfileViewContext: ViewContext {
    var common: Future<CommonViewContext>?
    let user: User
    init(user: User) {
        self.user = user
    }
}
