import SwiftUI

extension Color {
    func toHex() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format:"#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
    static func fromHex(_ hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = Int(s, radix: 16) else { return .gray }
        return Color(
            red: Double((v>>16)&0xFF)/255,
            green: Double((v>>8)&0xFF)/255,
            blue: Double(v&0xFF)/255
        )
    }
}
