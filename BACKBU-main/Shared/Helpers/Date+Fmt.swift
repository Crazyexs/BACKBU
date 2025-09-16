import Foundation
extension Date {
    var iso8601: String { ISO8601DateFormatter().string(from: self) }
}
