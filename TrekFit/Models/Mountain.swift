import Foundation

// MARK: - Mountain
struct Mountain: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let route: String
    let minimumVO2Max: Double
}

// MARK: - Sample Data
extension Mountain {
    static let sampleMountains: [Mountain] = [
        Mountain(
            name: "Mount Prau",
            route: "via Patak Banteng",
            minimumVO2Max: 35.0
        ),
        Mountain(
            name: "Mount Gede",
            route: "via Cibodas",
            minimumVO2Max: 37.6
        ),
        Mountain(
            name: "Mount Semeru",
            route: "via Ranu Pani",
            minimumVO2Max: 38.4
        )
    ]
}
