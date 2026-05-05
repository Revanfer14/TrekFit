import SwiftUI

struct MountainCardView: View {
    let mountain: Mountain
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(mountain.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image("routeIcon") // Make sure this is in your Assets.xcassets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        
                        Text(mountain.route)
                            .font(.subheadline)
                            .foregroundColor(Color(.systemGray))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("AccentOrange"))
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
