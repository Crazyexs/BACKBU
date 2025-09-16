import Foundation

enum ExportService {
    static func gpx(for trip: Trip) -> Data {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="TripTracker" xmlns="http://www.topografix.com/GPX/1/1">
        <trk><name>\(trip.startedAt)</name><trkseg>
        """
        for p in trip.points {
            xml += """
            <trkpt lat="\(p.coord.latitude)" lon="\(p.coord.longitude)">
              <time>\(p.timestamp.iso8601)</time>
              <extensions><speed>\(p.speedKmh/3.6)</speed></extensions>
            </trkpt>
            """
        }
        xml += "</trkseg></trk></gpx>"
        return Data(xml.utf8)
    }

    static func csv(for trip: Trip) -> Data {
        var s = "timestamp,lat,lon,speed_kmh,accuracy_m,alt_m\n"
        for p in trip.points {
            s += "\(p.timestamp.iso8601),\(p.coord.latitude),\(p.coord.longitude),\(String(format:"%.2f",p.speedKmh)),\(p.accuracy),\(p.altitude ?? .nan)\n"
        }
        return Data(s.utf8)
    }
}
