//
//  SelectMountainView.swift
//  TrekFit
//
//  View: SelectMountainView
//  Displays a scrollable list of mountain cards and a bottom search bar.
//
//  Navigation outcomes:
//    - User taps "Select" → saves mountain to MountainStorage → goes to ConnectWatchView
//    - User taps "Skip"   → saves nil to MountainStorage      → goes to ConnectWatchView
//    - User taps back     → returns to SetProfileView
//
//  The selected mountain is persisted via MountainStorage (UserDefaults) so that
//  ResultView — which sits after the entire Chester test flow — can retrieve it
//  without needing it passed through every intermediate screen.
//

import SwiftUI

// MARK: - SelectMountainView

struct SelectMountainView: View {

    // MARK: - ViewModel

    @StateObject private var viewModel = SelectMountainViewModel()

    // MARK: - Injected

    /// User profile passed from SetProfileView — forwarded to ConnectWatchView is not needed,
    /// but kept here in case future screens need it.
    let userProfile: UserProfile

    // MARK: - Navigation State

    @Environment(\.dismiss) private var dismiss
    @State private var navigateToWatch: Bool = false

    // MARK: - Body

    var body: some View {
        let _ = print("🏔️ SelectMountainView body rendered")
        let _ = print("🏔️ navigateToWatch: \(navigateToWatch)")
        ZStack(alignment: .bottom) {

            Color(.systemBackground).ignoresSafeArea()

            // ── Scrollable Mountain Cards ─────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.filteredMountains) { mountain in
                        MountainCardView(mountain: mountain) {
                            print("🏔️ Mountain selected, navigateToWatch = true")
                            MountainStorage.save(mountain)
                            navigateToWatch = true
                        }
                    }
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            // ── Search Bar pinned to bottom ───────────────────────────────
            searchBar
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        .navigationTitle("Select Mountain")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Back → returns to SetProfileView
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }

            // Skip → no mountain selected, proceed to watch pairing
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    MountainStorage.save(nil)   // persist "no mountain" explicitly
                    navigateToWatch = true
                } label: {
                    Text("Skip")
                        .font(.body)
                        .foregroundColor(Color("AccentOrange"))
                }
            }
        }
        .navigationDestination(isPresented: $navigateToWatch) {
            ConnectWatchView()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray))
                .font(.system(size: 15))

            TextField("Search Mountain", text: $viewModel.searchQuery)
                .font(.body)
                .autocorrectionDisabled()

            if !viewModel.searchQuery.isEmpty {
                Button { viewModel.searchQuery = "" } label: {
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
