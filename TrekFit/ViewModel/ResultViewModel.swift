import Foundation
import Combine

final class ResultViewModel: ObservableObject {
    let result: TestResult
    let allMountains: [Mountain]

    @Published var currentSelectedMountain: Mountain?
    @Published var showMountainPicker: Bool = false

    init(result: TestResult, allMountains: [Mountain] = Mountain.sampleMountains) {
        self.result = result
        self.allMountains = allMountains
        self.currentSelectedMountain = result.selectedMountain
    }

    var formattedUserVO2Max: String { String(format: "%.1f", result.userVO2Max) }

    var formattedMountainVO2Max: String {
        guard let mountain = currentSelectedMountain else { return "--" }
        return String(format: "%.1f", mountain.minimumVO2Max)
    }

    var shortMountainName: String {
        guard let name = currentSelectedMountain?.name else { return "" }
        return name.replacingOccurrences(of: "Mount ", with: "Mt. ")
    }

    var isMountainSelected: Bool { currentSelectedMountain != nil }

    // MARK: - Color Logic
    
    /// User VO2 card color: Green if passed OR skipped. Red if failed.
    var userCardStyle: VO2MaxCardView.CardStyle {
        guard let mountain = currentSelectedMountain else { return .green }
        return result.userVO2Max >= mountain.minimumVO2Max ? .green : .red
    }

    // MARK: - Recommendation Logic
    
    var recommendedMountain: Mountain? {
        // Use the updated logic inside TestResult
        let current = TestResult(
            userVO2Max: result.userVO2Max,
            userName: result.userName,
            selectedMountain: currentSelectedMountain
        )
        return current.recommendedMountain(from: allMountains)
    }

    func selectNewMountain(_ mountain: Mountain) {
        currentSelectedMountain = mountain
        showMountainPicker = false
    }
}
