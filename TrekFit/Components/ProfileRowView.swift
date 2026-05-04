//
//  ProfileRowView.swift
//  TrekFit
//
//  Component: ProfileRowView
//  A single row inside the profile form card.
//  It shows a left-aligned label and a right-aligned value with an optional
//  chevron ("›") to signal that the row is tappable / navigable.
//
//  Usage:
//    ProfileRowView(label: "Name", value: "Jeson", showChevron: true)
//    ProfileRowView(label: "Age",  value: "22",    showChevron: false)
//

import SwiftUI

// MARK: - ProfileRowView

struct ProfileRowView: View {

    // MARK: - Inputs

    /// The left-side label text (e.g. "Name", "Gender")
    let label: String

    /// The right-side value text (e.g. "Jeson", "Male")
    let value: String

    /// When `true`, an orange chevron "›" is shown after the value,
    /// indicating the row opens a sheet or picker.
    var showChevron: Bool = false

    /// When `true`, the value is rendered inside a light rounded-rect badge.
    /// Used for the Date of Birth row to match the prototype.
    var valueBadged: Bool = false

    // MARK: - Body

    var body: some View {
        HStack {
            // --- Left: field label ---
            Text(label)
                .font(.body)                    // SF Pro Body Regular
                .foregroundColor(.primary)

            Spacer()

            // --- Right: value (plain or badged) ---
            if valueBadged {
                // Pill-shaped badge used for the date of birth field.
                // Light gray background (#E5E5EA) with dark text — matches prototype
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "E5E5EA"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                // Secondary label color — matches iOS system gray for value fields
                Text(value)
                    .font(.body)
                    .foregroundColor(Color(hex: "8E8E93"))
            }

            // --- Chevron indicator ---
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("AccentOrange"))   // #FF8D28
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        ProfileRowView(label: "Name",          value: "Jeson",        showChevron: true)
        Divider().overlay(Color(hex: "E6E6E6")).padding(.leading, 16)
        ProfileRowView(label: "Date of Birth", value: "Jan 7, 2004",  showChevron: false, valueBadged: true)
        Divider().overlay(Color(hex: "E6E6E6")).padding(.leading, 16)
        ProfileRowView(label: "Age",           value: "22",           showChevron: false)
        Divider().overlay(Color(hex: "E6E6E6")).padding(.leading, 16)
        ProfileRowView(label: "Gender",        value: "Male",         showChevron: true)
    }
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .padding()
}
