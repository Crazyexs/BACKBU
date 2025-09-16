import SwiftUI

struct SpeedSection: Codable, Identifiable, Equatable {
    let id: UUID
    var lower: Double
    var upper: Double
    var colorHex: String

    init(lower: Double, upper: Double, color: Color) {
        self.id = UUID(); self.lower = lower; self.upper = upper; self.colorHex = color.toHex()
    }
    func color() -> Color { Color.fromHex(colorHex) }
    func contains(_ kmh: Double) -> Bool { kmh >= lower && kmh < upper }
}

extension Array where Element == SpeedSection {
    static var `default`: [SpeedSection] = [
        .init(lower: 0,   upper: 20,  color: .blue),
        .init(lower: 20,  upper: 40,  color: .indigo),
        .init(lower: 40,  upper: 60,  color: .green),
        .init(lower: 60,  upper: 80,  color: .mint),
        .init(lower: 80,  upper: 100, color: .orange),
        .init(lower: 100, upper: .infinity, color: .red)
    ]
}
