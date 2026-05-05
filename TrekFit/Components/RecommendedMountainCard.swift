import SwiftUI

struct RecommendedMountainCard: View {
    let mountain: Mountain

    var body: some View {
        HStack(alignment: .center) {
            // Left: Mountain Name
            Text(mountain.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Right: Icon + VStack(Route, VO2)
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
