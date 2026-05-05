import SwiftUI

struct ResultView: View {
    @StateObject private var viewModel: ResultViewModel
    
    init(result: TestResult) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(result: result))
    }
    
    var body: some View {
        // Main VStack to separate the scrolling content from the pinned button
        VStack(spacing: 0) {
            
            // SCROLLING CONTENT
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hi, \(viewModel.result.userName)")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text("Here's Your Result")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    // 2. VO2 Cards + Compare Button
                    VStack(alignment: .trailing, spacing: 12) {
                        HStack(spacing: 12) {
                            // User Card (Green or Red)
                            VO2MaxCardView(
                                style: viewModel.userCardStyle,
                                label: "Your VO₂ max",
                                value: viewModel.formattedUserVO2Max,
                                iconName: "vo2icon", // Set this up in your assets
                                isFullWidth: !viewModel.isMountainSelected
                            )
                            
                            // Mountain Card (Always Black)
                            if viewModel.isMountainSelected {
                                VO2MaxCardView(
                                    style: .black,
                                    label: "Est. Minimum for\n\(viewModel.shortMountainName)",
                                    value: viewModel.formattedMountainVO2Max,
                                    iconName: "mountainIcon" // Set this up in your assets
                                )
                            }
                        }
                        
                        // Compare Button
                        if viewModel.isMountainSelected {
                            Button {
                                viewModel.showMountainPicker = true
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
                    }
                    
                    // 3. Recommended Mountain Section
                    if let recommended = viewModel.recommendedMountain {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RECOMMENDED MOUNTAIN")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .kerning(0.5)
                            
                            RecommendedMountainCard(mountain: recommended)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            
            // 4. PINNED BOTTOM SECTION (Outside the ScrollView)
            VStack(spacing: 16) {
                Text("These results only reflect your aerobic capacity for trekking, not full hiking readiness")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                
                Button(action: {
                    // Save Data Log Action
                }) {
                    Text("Save Data Log")
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
            .background(Color(.systemBackground)) // Prevents scrolling content from bleeding behind it
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showMountainPicker) {
            // Reusing the SelectMountain style for the bottom sheet
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.allMountains) { mountain in
                            MountainCardView(mountain: mountain) {
                                viewModel.selectNewMountain(mountain)
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
                        Button("Cancel") { viewModel.showMountainPicker = false }
                    }
                }
            }
            .presentationDetents([.large])
        }
    }
}



#Preview("37.0 VO2 - Fails Semeru (38.4)") {
    let dummyTest = ChesterTest.dummy
    
    let result = TestResult(
        userVO2Max: dummyTest.vo2max,
        userName: dummyTest.name,
        selectedMountain: Mountain.sampleMountains.first { $0.name == "Mount Semeru" }
    )
    
    return ResultView(result: result)
}
//
//#Preview("37.0 VO2 - Passes Prau (35.0)") {
//    let dummyTest = ChesterTest.dummy
//
//    let result = TestResult(
//        userVO2Max: dummyTest.vo2max,
//        userName: dummyTest.name,
//        selectedMountain: Mountain.sampleMountains.first { $0.name == "Mount Prau" }
//    )
//
//    return ResultView(result: result)
//}
//
//#Preview("37.0 VO2 - Skipped Mountain") {
//    let dummyTest = ChesterTest.dummy
//
//    let result = TestResult(
//        userVO2Max: dummyTest.vo2max,
//        userName: dummyTest.name,
//        selectedMountain: nil // Represents user pressing "Skip"
//    )
//
//    return ResultView(result: result)
//}
