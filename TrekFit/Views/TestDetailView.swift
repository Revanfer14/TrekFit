//
//  TestDetailView.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 05/05/26.
//

import SwiftUI

// MARK: - TestDetailView

struct TestDetailView: View {

    // MARK: - Input

    let record: VO2MaxRecord

    @Environment(\.dismiss) private var dismiss

    // MARK: - Derived State

    /// Mountain untuk record ini. Hanya akurat untuk record hari ini
    /// karena VO2MaxRecord belum menyimpan mountainId.
    /// Untuk record lama → solo VO2 card tanpa mountain comparison.
    private var mountain: Mountain? {
        let cal = Calendar.current
        guard cal.isDateInToday(record.date) else { return nil }
        return MountainStorage.load()
    }

    private var userPassesMountain: Bool {
        guard let m = mountain else { return false }
        return record.vo2Max >= m.minimumVO2Max
    }

    private var recommendedMountain: Mountain? {
        if let m = mountain, record.vo2Max >= m.minimumVO2Max { return nil }
        return Mountain.sampleMountains
            .filter { $0.minimumVO2Max <= record.vo2Max }
            .filter { $0.id != mountain?.id }
            .sorted { abs(record.vo2Max - $0.minimumVO2Max) < abs(record.vo2Max - $1.minimumVO2Max) }
            .first
    }

    private var formattedVO2: String {
        String(format: "%.1f", record.vo2Max)
    }

    private var shortMountainName: String {
        mountain?.name.replacingOccurrences(of: "Mount ", with: "Mt. ") ?? ""
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // ── SCROLLING CONTENT ─────────────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // 1. Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.formattedDate)
                            .font(.body)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            Text("Test Result")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            endReasonBadge
                        }
                    }

                    // 2. VO2 Cards
                    HStack(spacing: 12) {
                        VO2MaxCardView(
                            style: .black,
                            label: "Your VO₂ max",
                            value: formattedVO2,
                            iconName: "vo2icon",
                            isFullWidth: mountain == nil
                        )

                        if let m = mountain {
                            VO2MaxCardView(
                                style: .black,
                                label: "Est. Minimum for\n\(shortMountainName)",
                                value: String(format: "%.1f", m.minimumVO2Max),
                                iconName: "mountainIcon"
                            )
                        }
                    }

                    // 3. Stage Breakdown
                    stageBreakdown

                    // 4. Recommended Mountain
                    if let rec = recommendedMountain {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RECOMMENDED MOUNTAIN")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .kerning(0.5)

                            RecommendedMountainCard(mountain: rec)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }

            // ── PINNED BOTTOM SECTION ─────────────────────────────────────
            VStack(spacing: 16) {
                Text("These results only reflect your aerobic capacity for trekking, not full hiking readiness")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)

                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color("AccentOrange"))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Test Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - End Reason Badge

    private var endReasonBadge: some View {
        let isComplete = record.stage == 5
        return Text(isComplete ? "Completed" : "Stopped")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isComplete ? Color(hex: "34C759") : Color(hex: "FF9500"))
            .clipShape(Capsule())
    }

    // MARK: - Stage Breakdown

    private var stageBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("STAGE BREAKDOWN")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .kerning(0.5)

            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Stage")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Duration")
                        .frame(width: 80, alignment: .trailing)
                    Text("Status")
                        .frame(width: 70, alignment: .trailing)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(hex: "F2F2F7"))

                Divider().overlay(Color(hex: "E6E6E6"))

                ForEach(1...record.stage, id: \.self) { stageNum in
                    let isLastStage = stageNum == record.stage
                    let isComplete  = !isLastStage || record.stage == 5

                    HStack {
                        Text("Stage \(stageNum)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(isLastStage
                             ? String(format: "%d:%02d", record.durationMinutes, record.durationSeconds)
                             : "2:00")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .trailing)

                        Text(isComplete ? "Complete" : "Stopped")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(isComplete ? Color(hex: "34C759") : Color(hex: "FF9500"))
                            .frame(width: 70, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if stageNum < record.stage {
                        Divider()
                            .overlay(Color(hex: "E6E6E6"))
                            .padding(.leading, 16)
                    }
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
}

// MARK: - Preview

#Preview("Completed — Today (with Mountain)") {
    NavigationStack {
        TestDetailView(record: VO2MaxRecord(
            date: Date(),
            stage: 5,
            durationMinutes: 10,
            durationSeconds: 0,
            vo2Max: 38.4
        ))
    }
}

#Preview("Stopped — Older Record (no Mountain)") {
    NavigationStack {
        TestDetailView(record: VO2MaxRecord(
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            stage: 3,
            durationMinutes: 6,
            durationSeconds: 12,
            vo2Max: 36.8
        ))
    }
}
