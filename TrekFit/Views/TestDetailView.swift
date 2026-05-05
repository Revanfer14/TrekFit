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

    // MARK: - State

    @State private var selectedMountain: Mountain?
    @State private var showMountainPicker = false

    // Inisialisasi State awal berdasarkan tanggal record
    init(record: VO2MaxRecord, initialMountain: Mountain? = nil) {
            self.record = record
            
            // Jika ada initialMountain yang dipassing (dari Preview), gunakan itu
            if let initialMountain = initialMountain {
                _selectedMountain = State(initialValue: initialMountain)
            } else {
                // Jika tidak, jalankan logika normal (dari Aplikasi Asli)
                let cal = Calendar.current
                if cal.isDateInToday(record.date) {
                    _selectedMountain = State(initialValue: MountainStorage.load())
                } else {
                    _selectedMountain = State(initialValue: nil)
                }
            }
        }

    // MARK: - Derived State

    private var userPassesMountain: Bool {
        guard let m = selectedMountain else { return false }
        return record.vo2Max >= m.minimumVO2Max
    }

    private var formattedVO2: String {
        String(format: "%.1f", record.vo2Max)
    }

    private var shortMountainName: String {
        selectedMountain?.name.replacingOccurrences(of: "Mount ", with: "Mt. ") ?? ""
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

                    // 2. VO2 Cards + Compare Button
                    VStack(alignment: .trailing, spacing: 12) {
                        HStack(spacing: 12) {
                            // User Card (Green or Red)
                            VO2MaxCardView(
                                style: selectedMountain == nil ? .black : (userPassesMountain ? .green : .red),
                                label: "Your VO₂ max",
                                value: formattedVO2,
                                iconName: "vo2icon",
                                isFullWidth: selectedMountain == nil
                            )
                            
                            // Mountain Card (Always Black)
                            if let m = selectedMountain {
                                VO2MaxCardView(
                                    style: .black,
                                    label: "Est. Minimum for\n\(shortMountainName)",
                                    value: String(format: "%.1f", m.minimumVO2Max),
                                    iconName: "mountainIcon"
                                )
                            }
                        }
                        
                        // Compare Button
                        Button {
                            showMountainPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Result with another mountain")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(Color(hex: "007AFF"))
                        }
                        .buttonStyle(.plain)
                        
                    }

                    // 3. Stage Breakdown
                    stageBreakdown
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
        
        // ── MOUNTAIN PICKER SHEET ─────────────────────────────────────
        .sheet(isPresented: $showMountainPicker) {
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Mountain.sampleMountains) { mountain in
                            MountainCardView(mountain: mountain) {
                                selectedMountain = mountain
                                showMountainPicker = false
                            }
                        }
                    }
                    .padding(24)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Compare Mountain")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showMountainPicker = false }
                    }
                }
            }
            .presentationDetents([.large])
        }
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

#Preview("Completed — Today (with Mountain)") {
    NavigationStack {
        TestDetailView(
            record: VO2MaxRecord(
                date: Date(),
                stage: 5,
                durationMinutes: 10,
                durationSeconds: 0,
                vo2Max: 38.4
            ),
            // Suntikkan dummy mountain agar Compare Button & Mountain Card muncul
            initialMountain: Mountain.sampleMountains.first { $0.name == "Mount Semeru" } ?? Mountain.sampleMountains.first
        )
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
