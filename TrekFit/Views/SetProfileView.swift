import SwiftUI

struct SetProfileView: View {
    /// Injected from ContentView via LandingView
    @ObservedObject var viewModel: SetProfileViewModel
    
    // MARK: - Navigation
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Local Sheet State
    @State private var showNameSheet: Bool = false
    @State private var showDateSheet: Bool = false
    @State private var showGenderSheet: Bool = false
    @State private var showWeightSheet: Bool = false
    
    // MARK: - Validation
    @State private var navigateToSelectMountain: Bool = false
    var isEditMode: Bool = false
    
    var body: some View {
        let _ = print("📝 SetProfileView rendered")
        ZStack {
            Color(hex: "FFFFFF")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("We use these details strictly to calculate your personalized fitness score for the Chester Step Test.")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                formCard
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                Spacer()
                
                // MARK: CTA Button & Navigation
                if !isEditMode {
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
    private var formCard: some View {
        VStack(spacing: 0) {
            
            // Name
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
            
            // Date of Birth
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
            
            // Age (auto-computed)
            ProfileRowView(
                label: "Age",
                value: "\(viewModel.draft.age)",
                showChevron: false
            )
            
            rowDivider
            
            // Gender
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
            
            // Weight
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
        
        // Card styling
        .background(Color(hex: "F2F2F7"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // Divider Styling
    private var rowDivider: some View {
        Divider()
            .overlay(Color(hex: "E6E6E6"))
            .padding(.leading, 16)
    }
}

// MARK: - NameInputSheet
private struct NameInputSheet: View {
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
private struct DatePickerSheet: View {
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
private struct GenderPickerSheet: View {
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
private struct WeightPickerSheet: View {
    @Binding var weight: Double
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedKg: Int = 50
    @State private var selectedDecimalIndex: Int = 0
    
    /// Available decimal options: 0.00, 0.05, 0.10 ... 0.95
    private let decimalOptions: [Double] = stride(from: 0.0, through: 0.95, by: 0.05).map { $0 }
    
    /// Range of valid whole kilograms
    private let kgRange = Array(1...250)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Label
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
                
                // Dual wheel pickers
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
                    
                    // Right wheel: grams
                    Picker("Grams", selection: $selectedDecimalIndex) {
                        ForEach(decimalOptions.indices, id: \.self) { index in
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
    private func syncWeight() {
        let decimal = decimalOptions[selectedDecimalIndex]
        weight = Double(selectedKg) + decimal
    }
    
    /// Splits the incoming weight Double into kg and decimal wheels on appear.
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

#Preview {
    SetProfileView(viewModel: SetProfileViewModel())
}
