import Foundation

extension Date {
    
    var dateTimeUserString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Bangkok")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 25200)
        return dateFormatter.string(from: self)
    }
    
}
