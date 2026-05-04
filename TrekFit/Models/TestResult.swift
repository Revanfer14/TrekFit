//
//  TestResult.swift
//  TrekFit
//
//  Model: TestResult
//  A lightweight bridge struct that carries the data ResultView needs.
//  It is constructed just before navigating to ResultView, combining:
//    - The vo2max extracted from ChesterTest
//    - The optional Mountain the user selected (nil if they skipped)
//
//  This decouples ResultView from SwiftData and from SelectMountainView's state,
//  making it easy to pass through NavigationLink and to unit test independently.
//

import Foundation

// MARK: - TestResult

/// Carries the minimum data set needed to render the Result screen.
struct TestResult {

    // MARK: - Properties

    /// The user's estimated VO2 Max in mL/kg/min, taken from ChesterTest.vo2max
    let userVO2Max: Double

    /// The user's display name, taken from UserProfile.name
    let userName: String

    /// The mountain the user selected before the test, or nil if they skipped selection.
    /// When nil, ResultView shows a single VO2 Max card with no comparison.
    let selectedMountain: Mountain?

    // MARK: - Computed Helpers

    /// True if a mountain was selected and the user meets or exceeds its minimum VO2 Max.
    /// Used to decide card color (green = pass, red = fail) and whether to show recommendation.
    var passesSelectedMountain: Bool {
        guard let mountain = selectedMountain else { return false }
        return userVO2Max >= mountain.minimumVO2Max
    }

    /// Finds the best recommended mountain from a pool:
    ///   - Must have minimumVO2Max ≤ userVO2Max (user is capable)
    ///   - Pick the one with the smallest gap (closest to userVO2Max from below)
    ///   - Returns nil if no mountain qualifies or user already passes selected mountain
    ///
    /// Algorithm:
    ///   1. Filter to only mountains the user can safely do (min ≤ userVO2Max)
    ///   2. Exclude the already-selected mountain (no point recommending the same one)
    ///   3. Sort by gap ascending (smallest gap first)
    ///   4. Return the first result
    func recommendedMountain(from allMountains: [Mountain]) -> Mountain? {
        // If user passes their selected mountain, no recommendation needed
        if let selected = selectedMountain, userVO2Max >= selected.minimumVO2Max {
            return nil
        }

        return allMountains
            .filter { $0.minimumVO2Max <= userVO2Max }          // user is capable
            .filter { $0.id != selectedMountain?.id }           // not the already-selected one
            .sorted { abs(userVO2Max - $0.minimumVO2Max) < abs(userVO2Max - $1.minimumVO2Max) }
            .first
    }
}
