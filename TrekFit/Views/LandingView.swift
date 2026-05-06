import SwiftUI

// MARK: - LandingView
struct LandingView: View {
    
    /// Received from ContentView
    /// ObservedObjects acts as a listener
    @ObservedObject var profileViewModel: SetProfileViewModel
    @State private var navigateToSetProfile: Bool = false
    
    var body: some View {
        let _ = print("🏠 LandingView rendered")
        NavigationStack {
            ZStack() {
                // ── Full-screen background image ──────────────────────────
                Image("landingPage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // ── Foreground content ────────────────────────────────────
                VStack(alignment: .leading, spacing: 16) {
                    
                    // App brand name
                    Text("TrekFit")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    // Tagline card
                    Text("Ready for the Peak?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(16)
                        .background(Color(hex: "3C3C43").opacity(0.60))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // Description card
                    Text("TrekFit ensures you're fit and ready for your next trek. We analyze your clinical mountain fitness to give you personalized peak recommendations.")
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(16)
                        .background(Color(hex: "3C3C43").opacity(0.60))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    Spacer()
                    
                    // Bottom: button + caption
                    VStack(spacing: 10) {
                        PrimaryButtonView(title: "Jump In") {
                            navigateToSetProfile = true
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.white)
                            Text("Takes approximately 15 minutes")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            // Navigate to SetProfileView when Jump In is tapped
            .navigationDestination(isPresented: $navigateToSetProfile) {
                SetProfileView(viewModel: profileViewModel)
            }
        }
    }
}

#Preview {
    LandingView(profileViewModel: SetProfileViewModel())
}
