//
//  ResultView.swift
//  TrekFit
//
//  View: ResultView
//  Displays the Chester Step Test result to the user.
//
//  Three display modes:
//
//  Mode A — Mountain selected, user PASSES (vo2max >= mountain minimum):
//    [Orange: User VO₂]  [Green: Mt. X minimum]
//    "Compare another mountain" link
//    MOUNTAIN PROFILE section (same card as SelectMountain, no Select button)
//
//  Mode B — Mountain selected, user FAILS (vo2max < mountain minimum):
//    [Orange: User VO₂]  [Red: Mt. X minimum]
//    "Compare another mountain" link
//    RECOMMENDED MOUNTAIN section (best safe alternative)
//
//  Mode C — No mountain selected (skipped):
//    [Orange: User VO₂ — full width]
//    RECOMMENDED MOUNTAIN section (best safe mountain)
//

import SwiftUI

// MARK: - ResultView

struct ResultView: View {

    // MARK: - ViewModel

    @StateObject private var viewModel: ResultViewModel

    // MARK: - Init

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
                if viewModel.isMountainSelected {
                    mountainSelectedCards       // Mode A or B: two cards side by side
                } else {
                    soloVO2Card                 // Mode C: one full-width card
                }

                // ── Mountain Profile (Mode A — user passes) ───────────────
                // Shows the chosen mountain card without a Select button
                if viewModel.isMountainSelected && viewModel.userPassesSelectedMountain,
                   let mountain = viewModel.currentSelectedMountain {
                    mountainProfileSection(mountain: mountain)
                }

                // ── Recommended Mountain (Mode B & C — user fails or skipped) ──
                // Shows the best safe mountain based on smallest-gap algorithm
                if let recommended = viewModel.recommendedMountain {
                    mountainSection(
                        title: "RECOMMENDED MOUNTAIN",
                        mountain: recommended
                    )
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

        // ── "Compare another mountain" bottom sheet ───────────────────────
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

    /// Mode A & B: Two side-by-side cards + "Compare another mountain" link below
    private var mountainSelectedCards: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {

                // Left card — user's VO2 Max, always orange
                VO2MaxCardView(
                    style: .orange,
                    label: "Your VO₂ max",
                    value: viewModel.formattedUserVO2Max
                )

                // Right card — mountain minimum
                // Green = user passes (≥ minimum), Red = user fails (< minimum)
                VO2MaxCardView(
                    style: viewModel.userPassesSelectedMountain ? .green : .red,
                    label: "Est. Min. for \(viewModel.shortMountainName)",   // "Mt. Rinjani" — short form
                    value: viewModel.formattedMountainVO2Max
                )
            }

            // "Compare another mountain" — tapping opens the mountain picker sheet
            Button {
                viewModel.showMountainPicker = true
            } label: {
                HStack(spacing: 4) {
                    Text("Compare another mountain")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "007AFF"))

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(Color(hex: "007AFF"))
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    /// Mode C: Single full-width orange VO2 card when no mountain was selected
    private var soloVO2Card: some View {
        VO2MaxCardView(
            style: .orange,
            label: "Your VO₂ max",
            value: viewModel.formattedUserVO2Max,
            isFullWidth: true
        )
    }

    /// Mode A — "MOUNTAIN PROFILE" section shown when user passes their selected mountain.
    /// Reuses MountainDetailCard (same layout as SelectMountain card, but without Select button).
    private func mountainProfileSection(mountain: Mountain) -> some View {
        mountainSection(title: "MOUNTAIN PROFILE", mountain: mountain)
    }

    /// Reusable section builder: a labeled header + a MountainDetailCard below it.
    /// Used for both "MOUNTAIN PROFILE" and "RECOMMENDED MOUNTAIN".
    private func mountainSection(title: String, mountain: Mountain) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Section header — all caps, small, gray
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(.systemGray))
                .kerning(0.5)

            // Mountain card without Select button — reusable component
            MountainDetailCard(mountain: mountain)
        }
    }

    /// Disclaimer + Save Data Log button pinned to the bottom of the scroll view
    private var bottomSection: some View {
        VStack(spacing: 16) {

            Text("These results only reflect your aerobic capacity for trekking, not full hiking readiness")
                .font(.caption)
                .foregroundColor(Color(.systemGray))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Save Data Log — no action in prototype stage
            PrimaryButtonView(title: "Save Data Log") {
                // TODO: Implement data log persistence in a future sprint
            }
        }
    }
}

// MARK: - MountainDetailCard

/// A read-only mountain card showing photo, name, height, and description.
/// Same visual as MountainCardView in SelectMountainView but WITHOUT the Select button.
/// Used in ResultView for both "Mountain Profile" and "Recommended Mountain" sections.
private struct MountainDetailCard: View {

    let mountain: Mountain

    private let photoHeight: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Mountain photo ────────────────────────────────────────────
            Image(mountain.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: photoHeight)
                .clipped()

            // ── Info section ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {

                // Name row (no Select button here — read-only)
                HStack(spacing: 6) {
                    Image("mountainIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)

                    Text(mountain.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                // Summit height
                Text(formattedHeight)
                    .font(.caption)
                    .foregroundColor(Color(.systemGray))

                // Short description (max 3 lines — same as SelectMountain card)
                Text(mountain.shortDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "E6E6E6"), lineWidth: 1)
        )
    }

    private var formattedHeight: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: mountain.summitHeight)) ?? "\(mountain.summitHeight)"
        return "\(formatted) m"
    }
}

// MARK: - MountainPickerSheet

/// Bottom sheet shown when user taps "Compare another mountain".
/// Reuses MountainCardView with search — selecting a mountain updates the comparison in ResultViewModel.
private struct MountainPickerSheet: View {

    @ObservedObject var viewModel: ResultViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredPickerMountains) { mountain in
                            MountainCardView(mountain: mountain) {
                                viewModel.selectNewMountain(mountain)
                            }
                        }
                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // Search bar pinned to bottom
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
            .navigationTitle("Compare Mountain")
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

// MARK: - Previews

#Preview("Mountain Selected — Fail") {
    NavigationStack {
        ResultView(result: TestResult(
            userVO2Max: 38.4,
            userName: "Axel",
            selectedMountain: Mountain.sampleMountains[1]   // Rinjani min 45 — user fails
        ))
    }
}

#Preview("Mountain Selected — Pass") {
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
