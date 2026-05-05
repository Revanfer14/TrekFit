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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                // Determine if we should use a custom asset or an SF symbol
                if style == .black {
                    Image("mountainIcon") // Custom mountain icon from your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                } else {
                    Image("vo2icon") // e.g., "vo2icon" from your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
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
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .frame(height: 160)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
