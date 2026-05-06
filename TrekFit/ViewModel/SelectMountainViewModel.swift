// CODE NOT USED ANYMORE (NO MORE SEARCH FUNCTIONALITY)

import Foundation
import Combine

// MARK: - SelectMountainViewModel
final class SelectMountainViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var mountains: [Mountain] = Mountain.sampleMountains

    // MARK: - Computed Properties
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
