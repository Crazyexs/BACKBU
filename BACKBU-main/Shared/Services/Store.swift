import Foundation

@MainActor
final class Store: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var speedSections: [SpeedSection] = .default
    @Published var speedZones: [SpeedZone] = []

    private var tripsURL: URL { AppGroup.containerURL.appendingPathComponent("data/trips.json") }
    private var sectionsURL: URL { AppGroup.containerURL.appendingPathComponent("data/speed_sections.json") }
    private var zonesURL: URL { AppGroup.containerURL.appendingPathComponent("data/speed_zones.json") }

    func load() async {
        if let d = FileIO.read(tripsURL), let v = try? JSONDecoder().decode([Trip].self, from: d) { trips = v }
        if let d = FileIO.read(sectionsURL), let v = try? JSONDecoder().decode([SpeedSection].self, from: d) { speedSections = v }
        if let d = FileIO.read(zonesURL), let v = try? JSONDecoder().decode([SpeedZone].self, from: d) { speedZones = v }
    }
    func save() async {
        let enc = JSONEncoder(); enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try? FileIO.write((try? enc.encode(trips)) ?? Data(), to: tripsURL)
        try? FileIO.write((try? enc.encode(speedSections)) ?? Data(), to: sectionsURL)
        try? FileIO.write((try? enc.encode(speedZones)) ?? Data(), to: zonesURL)
    }

    func add(_ trip: Trip) async { trips.insert(trip, at: 0); await save() }
    func update(_ trip: Trip) async { if let i = trips.firstIndex(where:{ $0.id == trip.id }) { trips[i] = trip; await save() } }
    func delete(_ set: IndexSet) async { trips.remove(atOffsets: set); await save() }
    func deleteAll() async { trips.removeAll(); await save() }
}
