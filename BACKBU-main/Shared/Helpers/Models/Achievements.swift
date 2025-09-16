import Foundation

enum Badge: String, Codable, CaseIterable {
    case km100, smooth, earlyBird, nightOwl
    var title: String {
        switch self {
        case .km100: return "100 km Day"
        case .smooth: return "Perfect Smoothness"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        }
    }
}

func earnedBadges(for trip: Trip) -> [Badge] {
    var out:[Badge]=[]
    if trip.distanceMeters >= 100_000 { out.append(.km100) }
    let diffs = zip(trip.points, trip.points.dropFirst()).map { abs($1.speedKmh - $0.speedKmh) }
    if (diffs.max() ?? 0) < 8 { out.append(.smooth) }
    let h = Calendar.current.component(.hour, from: trip.startedAt)
    if h < 6 { out.append(.earlyBird) }
    if h >= 22 { out.append(.nightOwl) }
    return out
}
