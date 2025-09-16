import Foundation

enum FileIO {
    static func write(_ data: Data, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }
    static func read(_ url: URL) -> Data? { try? Data(contentsOf: url) }
}
