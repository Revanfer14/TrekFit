//
//  ResultView.swift
//  TrekFit
//
//  View: ResultView
//  Displays the Chester Step Test result to the user.
//
//  Two display modes depending on whether a mountain was selected:
//
//  Mode A — Mountain selected:
//    ┌──────────────────────────────────────────────┐
//    │  Hi, [Name]                                  │
//    │  Here's Your Result                          │
//    │                                              │
//    │  [Orange: User VO₂] [Red/Green: Mountain]   │
//    │  Choose another mountain ↕                   │
//    │                                              │
//    │  RECOMMENDED MOUNTAIN (if user fails)        │
//    │  [RecommendedMountainCard]                   │
//    │                                              │
//    │  disclaimer                                  │
//    │  [Save Data Log]                             │
//    └──────────────────────────────────────────────┘
//
//  Mode B — No mountain selected (skipped):
//    ┌──────────────────────────────────────────────┐
//    │  Hi, [Name]                                  │
//    │  Here's Your Result                          │
//    │                                              │
//    │  [Orange: User VO₂ — full width]             │
//    │                                              │
//    │  RECOMMENDED MOUNTAIN                        │
//    │  [RecommendedMountainCard]                   │
//    │                                              │
//    │  disclaimer                                  │
//    │  [Save Data Log]                             │
//    └──────────────────────────────────────────────┘
//

import SwiftUI

// MARK: - ResultView

struct ResultView: View {

    // MARK: - ViewModel

    @StateObject private var viewModel: ResultViewModel

    // MARK: - Init

    /// Accepts a pre-built TestResult from the navigation flow.
    init(result: TestResult) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(result: result))
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // ── Greeting header ───────────────────────────────────────
                headerSection

                // ── VO2 Max cards ─────────────────────────────────────────
                // Layout changes based on whether a mountain is selected.
                if viewModel.isMountainSelected {
                    // Mode A: two cards side by side
                    mountainSelectedCards
                } else {
                    // Mode B: one full-width card
                    soloVO2Card
                }

                // ── Recommended Mountain ──────────────────────────────────
                // Shown when: user fails selected mountain OR no mountain was selected
                if let recommended = viewModel.recommendedMountain {
                    recommendedSection(mountain: recommended)
                }

                Spacer(minLength: 16)

                // ── Disclaimer + Save button ──────────────────────────────
                bottomSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)

        // ── "Choose another mountain" bottom sheet ────────────────────────
        .sheet(isPresented: $viewModel.showMountainPicker) {
            MountainPickerSheet(viewModel: viewModel)
        }
    }

    // MARK: - Subviews

    /// "Hi, [Name] / Here's Your Result" header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Hi, \(viewModel.result.userName)")
                .font(.body)
                .foregroundColor(.primary)

            Text("Here's Your Result")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }

    /// Mode A: Two cards side by side — user VO2 (orange) + mountain minimum (red/green)
    private var mountainSelectedCards: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {

                // User's VO2 Max — always orange
                VO2MaxCardView(
                    style: .orange,
                    label: "Your VO₂ max",
                    value: viewModel.formattedUserVO2Max
                )

                // Mountain minimum — green if user passes, red if user fails
                VO2MaxCardView(
                    style: viewModel.userPassesSelectedMountain ? .green : .red,
                    label: "Est. Minimum for \(viewModel.currentSelectedMountain?.name ?? "")",
                    value: viewModel.formattedMountainVO2Max
                )
            }

            // "Choose another mountain" link — only when mountain is selected
            Button {
                viewModel.showMountainPicker = true
            } label: {
                HStack(spacing: 4) {
                    Text("Choose another mountain")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "007AFF"))   // iOS system blue link color

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(Color(hex: "007AFF"))
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    /// Mode B: Single full-width orange card when no mountain was selected
    private var soloVO2Card: some View {
        VO2MaxCardView(
            style: .orange,
            label: "Your VO₂ max",
            value: viewModel.formattedUserVO2Max,
            isFullWidth: true
        )
    }

    /// Recommended mountain section — label + card
    private func recommendedSection(mountain: Mountain) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Section header label — all caps, small, gray
            Text("RECOMMENDED MOUNTAIN")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(.systemGray))
                .kerning(0.5)

            RecommendedMountainCard(mountain: mountain)
        }
    }

    /// Disclaimer text + Save Data Log button
    private var bottomSection: some View {
        VStack(spacing: 16) {

            // Disclaimer
            Text("These results only reflect your aerobic capacity for trekking, not full hiking readiness")
                .font(.caption)
                .foregroundColor(Color(.systemGray))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Save Data Log — no action yet (prototype)
            PrimaryButtonView(title: "Save Data Log") {
                // TODO: Implement data log persistence in a future sprint
            }
        }
    }
}

// MARK: - MountainPickerSheet

/// Bottom sheet reusing mountain list + search, presented when user taps "Choose another mountain".
/// Selecting a mountain updates the comparison target in ResultViewModel.
private struct MountainPickerSheet: View {

    /// Shared ViewModel — selection updates flow back to ResultView reactively
    @ObservedObject var viewModel: ResultViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredPickerMountains) { mountain in

                            // Reuse MountainCardView — Select triggers comparison update
                            MountainCardView(mountain: mountain) {
                                viewModel.selectNewMountain(mountain)
                            }
                        }
                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // Search bar pinned to bottom (same as SelectMountainView)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: 15))

                    TextField("Search Mountain", text: $viewModel.mountainPickerSearch)
                        .font(.body)
                        .autocorrectionDisabled()

                    if !viewModel.mountainPickerSearch.isEmpty {
                        Button { viewModel.mountainPickerSearch = "" } label: {
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
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .navigationTitle("Choose Mountain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview (Mountain Selected — fails)

#Preview("With Mountain — Fail") {
    NavigationStack {
        ResultView(result: TestResult(
            userVO2Max: 38.4,
            userName: "Axel",
            selectedMountain: Mountain.sampleMountains[1]   // Rinjani min 45 — user fails
        ))
    }
}

#Preview("With Mountain — Pass") {
    NavigationStack {
        ResultView(result: TestResult(
            userVO2Max: 38.4,
            userName: "Axel",
            selectedMountain: Mountain.sampleMountains[0]   // Gede min 35 — user passes
        ))
    }
}

#Preview("No Mountain Selected") {
    NavigationStack {
        ResultView(result: TestResult(
            userVO2Max: 38.4,
            userName: "Axel",
            selectedMountain: nil
        ))
    }
}
