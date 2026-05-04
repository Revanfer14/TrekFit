//
//  SelectMountainViewModel.swift
//  TrekFit
//
//  ViewModel: SelectMountainViewModel
//  Manages the state and filtering logic for the Select Mountain screen.
//
//  Responsibilities:
//    1. Hold the full list of available mountains
//    2. Hold the live search query text typed by the user
//    3. Expose a filtered list that the view renders — updated reactively whenever
//       the search query changes (via Combine's @Published + computed property)
//

import Foundation
import Combine

// MARK: - SelectMountainViewModel

/// ObservableObject so SelectMountainView can subscribe and re-render on state changes.
final class SelectMountainViewModel: ObservableObject {

    // MARK: - Published State

    /// The text the user has typed into the search bar.
    /// Every keystroke triggers a SwiftUI re-render of `filteredMountains`.
    @Published var searchQuery: String = ""

    /// The full, unfiltered list of mountains loaded at startup.
    /// In a production app this would be fetched from a remote API or local database.
    @Published var mountains: [Mountain] = Mountain.sampleMountains

    // MARK: - Computed Properties

    /// Returns the mountains to display after applying the current search query.
    ///
    /// Algorithm:
    ///   - If `searchQuery` is blank → return the full list (no filtering)
    ///   - Otherwise → case-insensitive prefix/contains match on the mountain name
    ///
    /// This runs synchronously on every access; acceptable for small local datasets.
    var filteredMountains: [Mountain] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)

        // Empty query → show everything
        guard !trimmed.isEmpty else { return mountains }

        // Filter by name containing the query string (case-insensitive)
        return mountains.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
