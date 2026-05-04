//
//  SelectMountainView.swift
//  TrekFit
//
//  View: SelectMountainView
//  Displays a scrollable list of mountain cards and a bottom search bar.
//  Navigated to after the user taps "Set Profile" on SetProfileView.
//
//  Layout (top → bottom):
//    1. Navigation bar  — back chevron + "Select Mountain" title
//    2. Scrollable area — one MountainCardView per filtered mountain
//    3. Search bar      — pinned to the bottom, filters the list as the user types
//

import SwiftUI

// MARK: - SelectMountainView

struct SelectMountainView: View {

    // MARK: - ViewModel

    /// Owns the mountain list and search filtering logic.
    /// `@StateObject` ensures it is created once and lives as long as this view.
    @StateObject private var viewModel = SelectMountainViewModel()

    // MARK: - Navigation

    /// Allows the back button to pop this view off the NavigationStack
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Background ────────────────────────────────────────────────
            Color(.systemBackground)
                .ignoresSafeArea()

            // ── Scrollable Mountain Cards ─────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 20) {

                    // Iterate over the filtered list — updates live as searchQuery changes.
                    // `\.id` uses Mountain's UUID so SwiftUI can diff the list efficiently.
                    ForEach(viewModel.filteredMountains) { mountain in
                        MountainCardView(mountain: mountain) {
                            // TODO: Handle mountain selection (navigate to fitness test screen)
                            // For now this is intentionally left empty (prototype stage)
                        }
                    }

                    // Bottom padding so the last card isn't hidden behind the search bar
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            // ── Search Bar (pinned to bottom) ─────────────────────────────
            searchBar
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        // MARK: Navigation Bar
        .navigationTitle("Select Mountain")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)        // hide default back button; we use custom
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Custom back button — matches the style on SetProfileView
                Button {
                    dismiss()                       // pops SelectMountainView off the stack
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // MARK: - Subviews

    /// The search bar pinned to the bottom of the screen.
    /// Bound to `viewModel.searchQuery` — every character typed re-filters the list.
    private var searchBar: some View {
        HStack(spacing: 8) {

            // Magnifying glass icon — SF Symbol "magnifyingglass"
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray))
                .font(.system(size: 15))

            // Live search text field
            TextField("Search Mountain", text: $viewModel.searchQuery)
                .font(.body)
                .autocorrectionDisabled()

            // Clear button — only visible when the user has typed something
            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray3))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(hex: "F2F2F7"))           // light grouped background
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SelectMountainView()
    }
}
