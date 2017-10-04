import Foundation
func save(bytes: [UInt8], path: String) -> Bool {
    let pointer = UnsafeBufferPointer(start: bytes, count: bytes.count)
    let data = Data(buffer: pointer)
    do {
        try data.write(to: URL(fileURLWithPath: path))
    }
    catch{
        return false
    }
    return true
}
