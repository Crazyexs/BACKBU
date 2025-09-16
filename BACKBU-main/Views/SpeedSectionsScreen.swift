import SwiftUI

struct SpeedSectionsScreen: View {
    @EnvironmentObject var state: AppState
    @State private var lower = 0.0
    @State private var upper = 20.0
    @State private var color: Color = .blue

    var body: some View {
        Form {
            Section("Add New Speed Section") {
                Stepper("Lower Bound: \(Int(lower)) km/h", value: $lower, in: 0...300, step: 5)
                Stepper("Upper Bound: \(upper == .infinity ? 999 : Int(upper)) km/h", value: $upper, in: 5...400, step: 5)
                ColorPicker("Color", selection: $color, supportsOpacity: false)
                Button { state.store.speedSections.append(.init(lower: lower, upper: upper, color: color)); Task { await state.store.save() } }
                label: { Label("Add Speed Section", systemImage: "plus") }
            }
            Section("Existing") {
                ForEach(state.store.speedSections) { s in
                    HStack { Circle().fill(s.color()).frame(width: 18, height: 18)
                        Text("\(Int(s.lower))–\(s.upper.isInfinite ? "∞" : "\(Int(s.upper))") km/h") ; Spacer() }
                }.onDelete {
                    state.store.speedSections.remove(atOffsets: $0); Task { await state.store.save() }
                }
            }
        }
        .navigationTitle("Speed Sections")
    }
}
