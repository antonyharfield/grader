import Vapor

struct UserData: Content {
    let name: String
    let username: String
    let image: File?
}
