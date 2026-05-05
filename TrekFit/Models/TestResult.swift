import Foundation

struct TestResult {
    let userVO2Max: Double
    let userName: String
    let selectedMountain: Mountain?

    func recommendedMountain(from allMountains: [Mountain]) -> Mountain? {
        // If user passes their selected mountain, recommend the same mountain back
        if let selected = selectedMountain, userVO2Max >= selected.minimumVO2Max {
            return selected
        }

        // If skipped or failed, find the closest fit they can safely do
        return allMountains
            .filter { $0.minimumVO2Max <= userVO2Max }
            .filter { $0.id != selectedMountain?.id }
            .sorted { abs(userVO2Max - $0.minimumVO2Max) < abs(userVO2Max - $1.minimumVO2Max) }
            .first
    }
}
