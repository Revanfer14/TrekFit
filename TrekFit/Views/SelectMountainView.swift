import SwiftUI

struct SelectMountainView: View {
    let userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToMeasure: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Instructions Text
                Text("Select the mountain you plan to hike to find out the required VO₂ max.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                
                // Cards list
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(Mountain.sampleMountains) { mountain in
                            MountainCardView(mountain: mountain) {
                                MountainStorage.save(mountain)
                                navigateToMeasure = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Select Mountain")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    MountainStorage.save(nil)   // persist "no mountain" explicitly
                    navigateToMeasure = true
                } label: {
                    Text("Skip")
                        .font(.body)
                        .foregroundColor(Color("AccentOrange"))
                }
            }
        }
        .navigationDestination(isPresented: $navigateToMeasure) {
            MeasureBoxView()
        }
    }
}
