//
//  SelectMountainView.swift
//  TrekFit
//
//  View: SelectMountainView
//  Displays a scrollable list of mountain cards and a bottom search bar.
//  Navigated to after the user taps "Set Profile" on SetProfileView.
//
//  Navigation outcomes:
//    - User taps "Select" on a card  → navigates to ResultView with selectedMountain set
//    - User taps "Skip"              → navigates to ResultView with selectedMountain nil
//    - User taps back chevron        → returns to SetProfileView
//
//  Layout (top → bottom):
//    1. Navigation bar  — back chevron + "Select Mountain" title + "Skip" trailing button
//    2. Scrollable area — one MountainCardView per filtered mountain
//    3. Search bar      — pinned to the bottom, filters the list as the user types
//

import SwiftUI

// MARK: - SelectMountainView

struct SelectMountainView: View {

    // MARK: - ViewModel

    /// Owns the mountain list and search filtering logic.
    @StateObject private var viewModel = SelectMountainViewModel()

    // MARK: - Injected Dependencies

    /// The user's profile — name is passed into TestResult for the result screen greeting
    let userProfile: UserProfile

    /// The dummy Chester Test result — in production this comes from the test flow.
    /// For now a static dummy is used so the result page renders correctly.
    let chesterTest: ChesterTest

    // MARK: - Navigation State

    /// Allows the back button to pop this view off the NavigationStack
    @Environment(\.dismiss) private var dismiss

    /// Drives navigation to ResultView — set when user selects or skips
    @State private var navigationResult: TestResult? = nil
    @State private var navigateToResult: Bool = false

    // MARK: - Init

    /// Default init uses the dummy Chester test so previews and prototypes work without real data.
    init(userProfile: UserProfile, chesterTest: ChesterTest = ChesterTest.dummy) {
        self.userProfile = userProfile
        self.chesterTest = chesterTest
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Background ────────────────────────────────────────────────
            Color(.systemBackground)
                .ignoresSafeArea()

            // ── Scrollable Mountain Cards ─────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 20) {

                    ForEach(viewModel.filteredMountains) { mountain in
                        MountainCardView(mountain: mountain) {
                            // User selected this mountain → build TestResult with it
                            navigationResult = TestResult(
                                userVO2Max: chesterTest.vo2max,
                                userName: chesterTest.name,       // name is now stored in ChesterTest
                                selectedMountain: mountain
                            )
                            navigateToResult = true
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

            // Hidden NavigationLink — activated when navigateToResult flips to true
            if let result = navigationResult {
                NavigationLink(
                    destination: ResultView(result: result),
                    isActive: $navigateToResult
                ) { EmptyView() }
            }
        }
        // MARK: Navigation Bar
        .navigationTitle("Select Mountain")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Back button — returns to SetProfileView
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }

            // Skip button — goes to ResultView without a mountain selected
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigationResult = TestResult(
                        userVO2Max: chesterTest.vo2max,
                        userName: chesterTest.name,           // name mirrored from UserProfile
                        selectedMountain: nil
                    )
                    navigateToResult = true
                } label: {
                    Text("Skip")
                        .font(.body)
                        .foregroundColor(Color("AccentOrange"))
                }
            }
        }
    }

    // MARK: - Subviews

    /// The search bar pinned to the bottom of the screen.
    private var searchBar: some View {
        HStack(spacing: 8) {

            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray))
                .font(.system(size: 15))

            TextField("Search Mountain", text: $viewModel.searchQuery)
                .font(.body)
                .autocorrectionDisabled()

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
        .background(Color(hex: "F2F2F7"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SelectMountainView(userProfile: .empty)
    }
}
