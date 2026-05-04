//
//  SetProfileView.swift
//  TrekFit
//
//  View: SetProfileView
//  The "Set Profile" onboarding screen where the user enters their name,
//  date of birth, and gender before starting the fitness test.
//
//  Layout (top → bottom):
//    1. Navigation bar  — back button (inactive for now) + "Set Profile" title
//    2. Form card       — Name / Date of Birth / Age / Gender rows
//    3. Spacer          — pushes button to the bottom
//    4. Primary button  — "Set Profile" CTA, saves data via ViewModel
//
//  Sheets presented:
//    • NameInputSheet   — text field for entering the user's name
//    • DatePickerSheet  — wheel date picker for date of birth
//    • GenderPickerSheet — segmented / list picker for gender
//

import SwiftUI

// MARK: - SetProfileView

struct SetProfileView: View {

    // MARK: - ViewModel

    /// All business logic (validation, persistence) lives here.
    /// `@StateObject` ensures the ViewModel is created once and owned by this view.
    @StateObject private var viewModel = SetProfileViewModel()

    // MARK: - Navigation

    /// Allows the back button to pop SetProfileView and return to LandingView
    @Environment(\.dismiss) private var dismiss

    // MARK: - Local Sheet State

    /// Controls visibility of the name-entry sheet
    @State private var showNameSheet: Bool = false

    /// Controls visibility of the date-of-birth picker sheet
    @State private var showDateSheet: Bool = false

    /// Controls visibility of the gender picker sheet
    @State private var showGenderSheet: Bool = false

    /// Tracks whether the profile was saved successfully — triggers navigation to SelectMountainView
    @State private var navigateToSelectMountain: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack {
                // --- Screen background: #FFFFFF (design spec) ---
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // ── Form Card ──────────────────────────────────────────
                    formCard
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    Spacer()

                    // ── Primary CTA Button ─────────────────────────────────
                    // On successful save, flips `navigateToSelectMountain` to true,
                    // which activates the hidden NavigationLink below.
                    PrimaryButtonView(title: "Set Profile") {
                        let success = viewModel.saveProfile()
                        if success { navigateToSelectMountain = true }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)

                    // Hidden NavigationLink — activated programmatically via the bool flag.
                    // Using this pattern keeps the button UI fully custom (no default link styling).
                    NavigationLink(
                        destination: SelectMountainView(),
                        isActive: $navigateToSelectMountain
                    ) { EmptyView() }
                }
            }
            // MARK: Navigation Bar
            .navigationTitle("Set Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Back button — returns to LandingView by popping this view off the stack
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            // MARK: Sheets
            .sheet(isPresented: $showNameSheet) {
                NameInputSheet(name: $viewModel.draft.name)
            }
            .sheet(isPresented: $showDateSheet) {
                DatePickerSheet(dateOfBirth: $viewModel.draft.dateOfBirth)
            }
            .sheet(isPresented: $showGenderSheet) {
                GenderPickerSheet(gender: $viewModel.draft.gender)
            }
            // MARK: Validation Alert
            .alert("Incomplete Profile", isPresented: $viewModel.showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.validationMessage)
            }
    }

    // MARK: - Subviews

    /// The rounded card containing all four profile rows, separated by dividers.
    private var formCard: some View {
        VStack(spacing: 0) {

            // --- Row 1: Name ---
            // Tappable → opens NameInputSheet
            Button {
                showNameSheet = true
            } label: {
                ProfileRowView(
                    label: "Name",
                    value: viewModel.draft.name.isEmpty ? "Tap to enter" : viewModel.draft.name,
                    showChevron: true
                )
            }
            .buttonStyle(.plain)

            rowDivider

            // --- Row 2: Date of Birth ---
            // Tappable → opens DatePickerSheet
            // Value is shown inside a badge pill per the prototype
            Button {
                showDateSheet = true
            } label: {
                ProfileRowView(
                    label: "Date of Birth",
                    value: viewModel.formattedDateOfBirth,
                    showChevron: false,
                    valueBadged: true
                )
            }
            .buttonStyle(.plain)

            rowDivider

            // --- Row 3: Age ---
            // Read-only — auto-computed from dateOfBirth in the model
            ProfileRowView(
                label: "Age",
                value: "\(viewModel.draft.age)",
                showChevron: false
            )

            rowDivider

            // --- Row 4: Gender ---
            // Tappable → opens GenderPickerSheet
            Button {
                showGenderSheet = true
            } label: {
                ProfileRowView(
                    label: "Gender",
                    value: viewModel.draft.gender.description,
                    showChevron: true
                )
            }
            .buttonStyle(.plain)
        }
        // Card styling: light gray background (#F2F2F7), rounded corners, no shadow needed
        .background(Color(hex: "F2F2F7"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// A hairline divider with the spec separator color #E6E6E6 and consistent left indent.
    private var rowDivider: some View {
        Divider()
            .overlay(Color(hex: "E6E6E6"))
            .padding(.leading, 16)
    }
}

// MARK: - NameInputSheet

/// A bottom sheet with a text field for entering / editing the user's name.
private struct NameInputSheet: View {

    /// Two-way binding into the ViewModel's draft name
    @Binding var name: String

    /// Used to dismiss this sheet programmatically after saving
    @Environment(\.dismiss) private var dismiss

    /// Local buffer so the user can cancel without committing changes
    @State private var localName: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter your name")
                    .font(.headline)
                    .padding(.top, 8)

                TextField("e.g. Jeson", text: $localName)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        name = localName      // commit to the binding
                        dismiss()
                    }
                    .foregroundColor(Color("AccentOrange"))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { localName = name }   // pre-fill with existing value
        }
        .presentationDetents([.height(220)])
    }
}

// MARK: - DatePickerSheet

/// A bottom sheet with a wheel-style DatePicker for selecting date of birth.
private struct DatePickerSheet: View {

    /// Two-way binding into the ViewModel's draft dateOfBirth
    @Binding var dateOfBirth: Date

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DatePicker(
                "Date of Birth",
                selection: $dateOfBirth,
                in: ...Date(),              // cannot select a future date
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding(.horizontal, 16)
            .navigationTitle("Date of Birth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentOrange"))
                }
            }
        }
        .presentationDetents([.height(320)])
    }
}

// MARK: - GenderPickerSheet

/// A bottom sheet with a Picker for selecting gender.
private struct GenderPickerSheet: View {

    /// Two-way binding into the ViewModel's draft gender
    @Binding var gender: Gender

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Picker("Gender", selection: $gender) {
                ForEach(Gender.allCases, id: \.self) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .navigationTitle("Gender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentOrange"))
                }
            }
        }
        .presentationDetents([.height(260)])
    }
}

// MARK: - Preview

#Preview {
    SetProfileView()
}
