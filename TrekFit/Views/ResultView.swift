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
//    MOUNTAIN PROFILE — exact same card as SelectMountain (no Select button)
//
//  Mode B — Mountain selected, user FAILS (vo2max < mountain minimum):
//    [Orange: User VO₂]  [Red: Mt. X minimum]
//    "Compare another mountain" link
//    RECOMMENDED MOUNTAIN — best safe mountain card with Min. VO₂ badge
//
//  Mode C — No mountain selected (skipped):
//    [Orange: User VO₂ — full width]
//    RECOMMENDED MOUNTAIN — best safe mountain card with Min. VO₂ badge
//    (no "Compare another mountain" link)
//

import SwiftUI

// MARK: - ResultView

struct ResultView: View {

    @StateObject private var viewModel: ResultViewModel

    init(result: TestResult) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(result: result))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // ── Greeting ──────────────────────────────────────────────
                headerSection

                // ── VO2 Cards ─────────────────────────────────────────────
                if viewModel.isMountainSelected {
                    mountainSelectedCards           // Mode A or B: two cards side by side
                } else {
                    soloVO2Card                     // Mode C: single full-width card
                }

                // ── Mountain Profile (Mode A — passes selected mountain) ───
                // Shows exact same card as SelectMountain but without Select button
                if viewModel.isMountainSelected && viewModel.userPassesSelectedMountain,
                   let mountain = viewModel.currentSelectedMountain {
                    mountainSection(title: "MOUNTAIN PROFILE", mountain: mountain, showBadge: false)
                }

                // ── Recommended Mountain (Mode B & C — fails or skipped) ──
                // Shows a mountain card with the Min. VO₂ badge (no description)
                if let recommended = viewModel.recommendedMountain {
                    mountainSection(title: "RECOMMENDED MOUNTAIN", mountain: recommended, showBadge: true)
                }

                Spacer(minLength: 8)

                // ── Disclaimer + Save ─────────────────────────────────────
                bottomSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showMountainPicker) {
            MountainPickerSheet(viewModel: viewModel)
        }
    }

    // MARK: - Header

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

    // MARK: - VO2 Cards

    /// Mode A & B: Two side-by-side cards + "Compare another mountain" link
    private var mountainSelectedCards: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 12) {

                // Left — user VO2, always orange
                VO2MaxCardView(
                    style: .orange,
                    label: "Your VO₂ max",
                    value: viewModel.formattedUserVO2Max
                )

                // Right — mountain minimum, green if passes, red if fails
                VO2MaxCardView(
                    style: viewModel.userPassesSelectedMountain ? .green : .red,
                    label: "Est. Minimum. for \(viewModel.shortMountainName)",
                    value: viewModel.formattedMountainVO2Max
                )
            }

            // "Compare another mountain" — right-aligned, only when mountain is selected
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
        }
    }

    /// Mode C: Single full-width orange card when no mountain selected
    private var soloVO2Card: some View {
        VO2MaxCardView(
            style: .orange,
            label: "Your VO₂ max",
            value: viewModel.formattedUserVO2Max,
            isFullWidth: true
        )
    }

    // MARK: - Mountain Section Builder

    /// Reusable section: header label + mountain card.
    /// `showBadge: true`  → shows Min. VO₂ orange pill (Recommended Mountain)
    /// `showBadge: false` → shows card exactly like SelectMountain (Mountain Profile)
    private func mountainSection(title: String, mountain: Mountain, showBadge: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Section header — small caps gray label
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(.systemGray))
                .kerning(0.5)

            if showBadge {
                // Recommended Mountain card — photo + name/height + Min VO₂ badge (no description)
                MountainBadgeCard(mountain: mountain)
            } else {
                // Mountain Profile card — exact same as SelectMountain card without Select button
                MountainDetailCard(mountain: mountain)
            }
        }
    }

    // MARK: - Bottom Section

    /// Disclaimer with constrained width padding + Save Data Log button
    private var bottomSection: some View {
        VStack(spacing: 16) {

            // Disclaimer — padded horizontally so lines break shorter
            Text("These results only reflect your aerobic capacity for trekking, not full hiking readiness")
                .font(.caption)
                .foregroundColor(Color(.systemGray))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)   // extra side padding keeps lines short

            PrimaryButtonView(title: "Save Data Log") {
                // TODO: Implement data log persistence in a future sprint
            }
        }
    }
}

// MARK: - MountainDetailCard

/// Mountain card identical to SelectMountain's MountainCardView — photo + info — but WITHOUT
/// the Select button. Used for the "Mountain Profile" section (Mode A).
/// Reuses MountainInfoSection so layout is pixel-perfect with the select screen.
private struct MountainDetailCard: View {

    let mountain: Mountain
    private let photoHeight: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Image(mountain.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: photoHeight)
                .clipped()

            // No trailing view — EmptyView() gives us no button, matching the profile spec
            MountainInfoSection(mountain: mountain) {
                EmptyView()
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "E6E6E6"), lineWidth: 1)
        )
    }
}

// MARK: - MountainBadgeCard

/// Mountain card for the Recommended Mountain section.
/// Shows photo + name + height + orange Min. VO₂ pill badge.
/// No description text (matches prototype for recommended card).
private struct MountainBadgeCard: View {

    let mountain: Mountain
    private let photoHeight: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Image(mountain.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: photoHeight)
                .clipped()

            // Info row with Min. VO₂ badge as trailing view (no description below)
            HStack(alignment: .center) {

                // Left: mountain icon + name + height stacked
                VStack(alignment: .leading, spacing: 4) {

                    HStack(spacing: 4) {
                        Image("mountainIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)

                        Text(mountain.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }

                    Text(formattedHeight)
                        .font(.caption)
                        .foregroundColor(Color(.systemGray))
                }

                Spacer()

                // Right: Min. VO₂ max orange pill badge
                VStack(spacing: 2) {
                    Text("Min. VO₂ max :")
                        .font(.caption2)
                        .foregroundColor(.white)

                    Text("\(formattedMinVO2) ml/kg/min")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("AccentOrange"))
                .clipShape(Capsule())
            }
            .padding(14)
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

    private var formattedMinVO2: String {
        String(format: "%.1f", mountain.minimumVO2Max)
    }
}

// MARK: - MountainPickerSheet

/// Bottom sheet for "Compare another mountain" — reuses MountainCardView with search bar.
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

#Preview("Mountain — Fail (Recommended shown)") {
    NavigationStack {
        ResultView(result: TestResult(
            userVO2Max: 38.4,
            userName: "Axel",
            selectedMountain: Mountain.sampleMountains[1]   // Rinjani min 45 — fails
        ))
    }
}

#Preview("Mountain — Pass (Profile shown)") {
    NavigationStack {
        ResultView(result: TestResult(
            userVO2Max: 38.4,
            userName: "Axel",
            selectedMountain: Mountain.sampleMountains[0]   // Gede min 35 — passes
        ))
    }
}

#Preview("No Mountain (Recommended shown)") {
    NavigationStack {
        ResultView(result: TestResult(
            userVO2Max: 38.4,
            userName: "Axel",
            selectedMountain: nil
        ))
    }
}
