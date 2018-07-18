import Vapor

struct ChangePasswordData: Content {
    let currentPassword: String
    let newPassword: String
    let confirmNewPassword: String
}
