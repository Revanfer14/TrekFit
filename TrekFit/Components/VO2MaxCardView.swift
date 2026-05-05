import SwiftUI

struct VO2MaxCardView: View {
    enum CardStyle {
        case green, red, black
        
        var backgroundColor: Color {
            switch self {
                case .green: return Color(hex: "34C759")
                case .red:   return Color(hex: "FF383C")
                case .black: return Color.black
            }
        }
    }
    
    let style: CardStyle
    let label: String
    let value: String
    let iconName: String
    var isFullWidth: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                if style == .black {
                    Image("mountainIcon")
                } else {
                    Image("vo2icon")
                }
                
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(value)
                        .font(.system(size: isFullWidth ? 42 : 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("ml/kg/min")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .padding(16)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview("VO2 Max Card Variations") {
    ScrollView {
        VStack(spacing: 24) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Width (Skipped Mountain)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VO2MaxCardView(
                    style: .green,
                    label: "Your VO₂ max",
                    value: "42.1",
                    iconName: "vo2icon",
                    isFullWidth: true
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Side-by-Side: Pass State")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    VO2MaxCardView(
                        style: .green,
                        label: "Your VO₂ max",
                        value: "38.4",
                        iconName: "vo2icon"
                    )
                    
                    VO2MaxCardView(
                        style: .black,
                        label: "Est. Minimum for\nMt. Prau",
                        value: "35.0",
                        iconName: "mountainIcon"
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Side-by-Side: Fail State")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    VO2MaxCardView(
                        style: .red,
                        label: "Your VO₂ max",
                        value: "30.0",
                        iconName: "vo2icon"
                    )
                    
                    VO2MaxCardView(
                        style: .black,
                        label: "Est. Minimum for\nMt. Rinjani",
                        value: "45.0",
                        iconName: "mountainIcon"
                    )
                }
            }
        }
        .padding(24)
    }
}
