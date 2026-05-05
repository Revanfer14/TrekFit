import SwiftUI

struct RecommendedMountainCard: View {
    let mountain: Mountain

    var body: some View {
        HStack(alignment: .center) {
            Text(mountain.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image("routeIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mountain.route)
                        .font(.caption)
                        .foregroundColor(Color(.systemGray))
                    
                    Text("\(String(format: "%.1f", mountain.minimumVO2Max)) ml/kg/min")
                        .font(.caption)
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        
        RecommendedMountainCard(
            mountain: Mountain(
                name: "Mount Gede",
                route: "via Cibodas",
                minimumVO2Max: 37.6
            )
        )
        .padding()
    }
}
