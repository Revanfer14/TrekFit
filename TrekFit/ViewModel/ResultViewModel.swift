//
//  ResultViewModel.swift
//  TrekFit
//
//  ViewModel: ResultViewModel
//  Manages all display logic for ResultView.
//
//  Responsibilities:
//    1. Hold the TestResult received from the test/mountain selection flow
//    2. Expose formatted strings for the UI (VO2 Max, height, etc.)
//    3. Compute which mountain to recommend from the full list
//    4. Manage the "Choose another mountain" sheet state
//    5. Handle mountain re-selection from the bottom sheet
//

import Foundation
import Combine

// MARK: - ResultViewModel

final class ResultViewModel: ObservableObject {

    // MARK: - Inputs

    /// The test result passed in from the navigation flow
    let result: TestResult

    /// Full list of all mountains — used to compute recommendation
    let allMountains: [Mountain]

    // MARK: - Published State

    /// The mountain currently being compared (may change if user picks another)
    @Published var currentSelectedMountain: Mountain?

    /// Controls the "Choose another mountain" bottom sheet visibility
    @Published var showMountainPicker: Bool = false

    /// Search query inside the mountain picker sheet
    @Published var mountainPickerSearch: String = ""

    // MARK: - Init

    init(result: TestResult, allMountains: [Mountain] = Mountain.sampleMountains) {
        self.result = result
        self.allMountains = allMountains
        self.currentSelectedMountain = result.selectedMountain
    }

    // MARK: - Computed: VO2 Max display

    /// Formatted VO2 Max string for display (e.g. "38.4")
    var formattedUserVO2Max: String {
        String(format: "%.1f", result.userVO2Max)
    }

    /// Formatted minimum VO2 Max for the currently selected mountain
    var formattedMountainVO2Max: String {
        guard let mountain = currentSelectedMountain else { return "--" }
        return String(format: "%.1f", mountain.minimumVO2Max)
    }

    // MARK: - Computed: Comparison state

    /// Whether a mountain is currently selected for comparison
    var isMountainSelected: Bool {
        currentSelectedMountain != nil
    }

    /// True if user's VO2 Max meets or exceeds the selected mountain's minimum.
    /// Controls the red/green color of the mountain card.
    var userPassesSelectedMountain: Bool {
        guard let mountain = currentSelectedMountain else { return false }
        return result.userVO2Max >= mountain.minimumVO2Max
    }

    // MARK: - Computed: Recommendation

    /// The recommended mountain based on the smallest-gap algorithm defined in TestResult.
    /// Returns nil when the user already passes their selected mountain.
    ///
    /// When no mountain is selected (skip flow):
    ///   - Still computes a recommendation from all mountains
    ///   - Picks the mountain with the smallest gap below the user's VO2 Max
    var recommendedMountain: Mountain? {
        // Build a temporary TestResult using current state for recommendation logic
        let current = TestResult(
            userVO2Max: result.userVO2Max,
            userName: result.userName,
            selectedMountain: currentSelectedMountain
        )

        // If mountain selected and user passes → no recommendation needed
        if currentSelectedMountain != nil && userPassesSelectedMountain {
            return nil
        }

        // Find the mountain with the smallest gap the user can safely do
        return allMountains
            .filter { $0.minimumVO2Max <= result.userVO2Max }
            .filter { $0.id != currentSelectedMountain?.id }
            .sorted { abs(result.userVO2Max - $0.minimumVO2Max) < abs(result.userVO2Max - $1.minimumVO2Max) }
            .first
    }

    // MARK: - Computed: Filtered mountains for picker sheet

    /// Mountains filtered by the search query inside the picker sheet
    var filteredPickerMountains: [Mountain] {
        let trimmed = mountainPickerSearch.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return allMountains }
        return allMountains.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }

    // MARK: - Actions

    /// Called when user selects a mountain from the picker sheet.
    /// Updates the comparison target and dismisses the sheet.
    func selectNewMountain(_ mountain: Mountain) {
        currentSelectedMountain = mountain
        mountainPickerSearch = ""
        showMountainPicker = false
    }
}
