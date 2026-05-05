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
    
    /// Injected from ContentView via LandingView — NOT owned here.
    /// @ObservedObject means this view observes but does not create the ViewModel.
    @ObservedObject var viewModel: SetProfileViewModel
    
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
    
    /// Controls visibility of the weight picker sheet
    @State private var showWeightSheet: Bool = false
    
    /// Tracks whether the profile was saved successfully — triggers navigation to SelectMountainView
    @State private var navigateToSelectMountain: Bool = false
    
    /// Menentukan apakah view ini dibuka sebagai form Onboarding atau Edit Profil
    var isEditMode: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        let _ = print("📝 SetProfileView rendered")
        ZStack {
            // --- Screen background: #FFFFFF (design spec) ---
            Color(hex: "FFFFFF")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Warning Text
                Text("We use these details strictly to calculate your personalized fitness score for the Chester Step Test.")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                // ── Form Card ──────────────────────────────────────────
                formCard
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                Spacer()
                
                // MARK: CTA Button & Navigation
                // Hanya tampilkan tombol CTA bagian bawah jika BUKAN dalam mode edit
                if !isEditMode {
                    // Primary CTA Button — on successful save navigates to SelectMountainView
                    PrimaryButtonView(title: "Set Profile") {
                        let success = viewModel.saveProfile()
                        if success { navigateToSelectMountain = true }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .navigationDestination(isPresented: $navigateToSelectMountain) {
                        SelectMountainView(userProfile: viewModel.draft)
                    }
                }
            }
        }
        // MARK: Navigation Bar
        .navigationTitle(isEditMode ? "Edit Profile" : "Set Profile") // Opsional: Judul dinamis
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Back button — returns to LandingView by popping this view off the stack
                // Sembunyikan ikon back (<) jika sedang dalam mode Edit/Sheet
                if !isEditMode {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                    }
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
        .sheet(isPresented: $showWeightSheet) {
            WeightPickerSheet(weight: $viewModel.draft.weight)
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
            
            rowDivider
            
            // --- Row 5: Weight ---
            // Tappable → opens WeightPickerSheet (dual wheel: kg . grams)
            Button {
                showWeightSheet = true
            } label: {
                ProfileRowView(
                    label: "Weight (kg)",
                    value: viewModel.draft.weight <= 0 ? "Tap to enter" : viewModel.formattedWeight,
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
    
    /// Direct two-way binding into the ViewModel's draft name.
    /// No local buffer needed — binding directly eliminates the re-render lag.
    @Binding var name: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter your name")
                    .font(.headline)
                    .padding(.top, 8)
                
                // Bound directly to the ViewModel property.
                // Removing the localName copy removes the extra @State layer
                // that was causing keyboard and typing lag on real devices.
                TextField("e.g. Jeson", text: $name)
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
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentOrange"))
                }
            }
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

// MARK: - WeightPickerSheet

/// A bottom sheet with two side-by-side wheel pickers for weight entry.
/// Left wheel: whole kilograms (1–250)
/// Right wheel: decimal grams in steps of 0.5 shown as 00–99 (0, 5, 10 ... 95)
///
/// The two wheels combine to form a value like 64.50 kg.
/// Binding writes directly to `UserProfile.weight: Double` on every wheel change.
private struct WeightPickerSheet: View {
    
    /// Two-way binding into the ViewModel's draft weight (e.g. 64.5)
    @Binding var weight: Double
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Local wheel state
    
    /// Whole kilogram component (e.g. 64)
    @State private var selectedKg: Int = 50
    
    /// Decimal component index into `decimalOptions` (e.g. index 10 = 0.50)
    @State private var selectedDecimalIndex: Int = 0
    
    /// Available decimal options: 0.00, 0.05, 0.10 ... 0.95
    /// Displayed as "00", "05", "10" ... "95"
    private let decimalOptions: [Double] = stride(from: 0.0, through: 0.95, by: 0.05).map { $0 }
    
    /// Range of valid whole kilograms
    private let kgRange = Array(1...250)
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // --- Label row above the pickers ---
                HStack {
                    Text("kg")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                        .frame(maxWidth: .infinity)
                    
                    Text(".")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("g")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)
                .padding(.horizontal, 40)
                
                // --- Dual wheel pickers ---
                HStack(spacing: 0) {
                    
                    // Left wheel: whole kilograms
                    Picker("Kilograms", selection: $selectedKg) {
                        ForEach(kgRange, id: \.self) { kg in
                            Text("\(kg)").tag(kg)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    // Update weight binding whenever kg wheel changes
                    .onChange(of: selectedKg) { syncWeight() }
                    
                    // Dot separator
                    Text(".")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    
                    // Right wheel: decimal grams (00, 05, 10 ... 95)
                    Picker("Grams", selection: $selectedDecimalIndex) {
                        ForEach(decimalOptions.indices, id: \.self) { index in
                            // Format as two-digit string: 0.0 → "00", 0.05 → "05"
                            Text(String(format: "%02d", Int(decimalOptions[index] * 100)))
                                .tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    .onChange(of: selectedDecimalIndex) { syncWeight() }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Weight (kg)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentOrange"))
                }
            }
            // Pre-fill wheels from the current weight value when sheet opens
            .onAppear { loadFromWeight() }
        }
        .presentationDetents([.height(340)])
    }
    
    // MARK: - Helpers
    
    /// Combines the two wheel values and writes the result to the weight binding.
    /// e.g. selectedKg = 64, decimalOptions[10] = 0.50 → weight = 64.50
    private func syncWeight() {
        let decimal = decimalOptions[selectedDecimalIndex]
        weight = Double(selectedKg) + decimal
    }
    
    /// Splits the incoming weight Double into kg and decimal wheels on appear.
    /// e.g. weight = 64.5 → selectedKg = 64, selectedDecimalIndex = 10 (0.50)
    private func loadFromWeight() {
        guard weight > 0 else {
            selectedKg = 50
            selectedDecimalIndex = 0
            return
        }
        selectedKg = min(max(Int(weight), 1), 250)
        
        // Find the closest decimal option index
        let decimal = weight - Double(Int(weight))
        let closest = decimalOptions.enumerated().min(by: {
            abs($0.element - decimal) < abs($1.element - decimal)
        })
        selectedDecimalIndex = closest?.offset ?? 0
    }
}

// MARK: - Preview

#Preview {
    SetProfileView(viewModel: SetProfileViewModel())
}
