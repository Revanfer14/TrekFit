//
//  LogHistoryView.swift
//  TrekFit
//
//  Created by Jeson Adhi Dharma on 04/05/26.
//

import SwiftUI

// MARK: - Data Model

struct VO2MaxRecord: Identifiable {
    let id = UUID()
    let date: Date
    let stage: Int
    let durationMinutes: Int
    let durationSeconds: Int
    let vo2Max: Double

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        return formatter.string(from: date)
    }

    var durationText: String {
        "Stage \(stage), \(durationMinutes)m \(durationSeconds)s"
    }
}

// MARK: - Sample Data

extension VO2MaxRecord {
    static let sampleData: [VO2MaxRecord] = {
        let cal = Calendar.current
        let today = Date()

        func daysAgo(_ n: Int) -> Date {
            cal.date(byAdding: .day, value: -n, to: today) ?? today
        }

        return [
            VO2MaxRecord(date: today,          stage: 3, durationMinutes: 6, durationSeconds: 12, vo2Max: 38.4),
            VO2MaxRecord(date: daysAgo(1),     stage: 3, durationMinutes: 6, durationSeconds: 12, vo2Max: 37.1),
            VO2MaxRecord(date: daysAgo(3),     stage: 3, durationMinutes: 6, durationSeconds: 12, vo2Max: 38.4),
            VO2MaxRecord(date: daysAgo(8),     stage: 2, durationMinutes: 5, durationSeconds: 45, vo2Max: 36.8),
            VO2MaxRecord(date: daysAgo(12),    stage: 3, durationMinutes: 6, durationSeconds: 0,  vo2Max: 37.9),
            VO2MaxRecord(date: daysAgo(16),    stage: 2, durationMinutes: 5, durationSeconds: 30, vo2Max: 35.5),
            VO2MaxRecord(date: daysAgo(20),    stage: 1, durationMinutes: 4, durationSeconds: 55, vo2Max: 34.2),
            VO2MaxRecord(date: daysAgo(25),    stage: 1, durationMinutes: 4, durationSeconds: 20, vo2Max: 33.7),
        ]
    }()
}

// MARK: - Grouping Helper

struct HistoryGroup {
    let title: String
    let records: [VO2MaxRecord]
}

func groupRecords(_ records: [VO2MaxRecord]) -> [HistoryGroup] {
    let cal = Calendar.current
    let today = Date()

    let startOfToday   = cal.startOfDay(for: today)
    let startOfWeek    = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
    let startOfMonth   = cal.date(from: cal.dateComponents([.year, .month], from: today))!

    var todayGroup:     [VO2MaxRecord] = []
    var thisWeekGroup:  [VO2MaxRecord] = []
    var thisMonthGroup: [VO2MaxRecord] = []
    var olderGroup:     [VO2MaxRecord] = []

    for record in records {
        let recordDay = cal.startOfDay(for: record.date)
        if recordDay >= startOfToday {
            todayGroup.append(record)
        } else if recordDay >= startOfWeek {
            thisWeekGroup.append(record)
        } else if recordDay >= startOfMonth {
            thisMonthGroup.append(record)
        } else {
            olderGroup.append(record)
        }
    }

    var groups: [HistoryGroup] = []
    if !todayGroup.isEmpty     { groups.append(HistoryGroup(title: "TODAY",      records: todayGroup))     }
    if !thisWeekGroup.isEmpty  { groups.append(HistoryGroup(title: "THIS WEEK",  records: thisWeekGroup))  }
    if !thisMonthGroup.isEmpty { groups.append(HistoryGroup(title: "THIS MONTH", records: thisMonthGroup)) }
    if !olderGroup.isEmpty     { groups.append(HistoryGroup(title: "OLDER",      records: olderGroup))     }
    return groups
}

// MARK: - Best Result Card

struct BestResultCard: View {
    let bestVO2Max: Double

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.95, green: 0.55, blue: 0.10))

            // Content
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    // Icon
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()

                    Text("Best VO2 Max\nResult")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(2)
                }

                Spacer()

                // Value
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", bestVO2Max))
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    Text("ml/kg/min")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .frame(height: 130)
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let record: VO2MaxRecord

    var body: some View {
        HStack(spacing: 14) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 44, height: 44)

                Image(systemName: "figure.run")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Date & stage
            VStack(alignment: .leading, spacing: 3) {
                Text(record.formattedDate)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(record.durationText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // VO2 Max value
            HStack(spacing: 4) {
                Text(String(format: "%.1f", record.vo2Max))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0.95, green: 0.55, blue: 0.10))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.secondary)
            .tracking(0.5)
    }
}

// MARK: - Main View

struct HistoryLogView: View {
    let userName: String = "Axel"
    let records: [VO2MaxRecord] = VO2MaxRecord.sampleData

    var bestVO2Max: Double {
        records.map(\.vo2Max).max() ?? 0
    }

    var groups: [HistoryGroup] {
        groupRecords(records)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Greeting
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome back \(userName),")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)

                        Text("Here's your log")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)

                    // MARK: Best Result Card
                    BestResultCard(bestVO2Max: bestVO2Max)
                        .padding(.horizontal)

                    // MARK: History Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("History")
                                .font(.system(size: 22, weight: .bold))

                            Spacer()

                            Button("View All") {
                                // Navigate to full list
                            }
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        }
                        .padding(.horizontal)

                        // Grouped rows
                        ForEach(groups, id: \.title) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: group.title)
                                    .padding(.horizontal)

                                VStack(spacing: 8) {
                                    ForEach(group.records) { record in
                                        HistoryRow(record: record)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // back action
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("History Log")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryLogView()
}
