import SwiftUI

struct ProfileRowView: View {
    let label: String // text for input guidance
    let value: String // text for value placeholder
    var showChevron: Bool = false
    
    /// When `true`, the value is rendered inside a rounded badge, not only normal text placeholder
    /// Used for the Date of Birth row
    var valueBadged: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // plain or badged
            if valueBadged { // only for Date of Birth
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "E5E5EA"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else { // plain text placeholder
                Text(value)
                    .font(.body)
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            // Chevron indicator
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("AccentOrange"))   // #FF8D28
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 0) {
        ProfileRowView(label: "Name", value: "Jeson", showChevron: true)
        Divider().overlay(Color(hex: "E6E6E6")).padding(.leading, 16)
        ProfileRowView(label: "Date of Birth", value: "Jan 7, 2004", showChevron: false, valueBadged: true)
        Divider().overlay(Color(hex: "E6E6E6")).padding(.leading, 16)
        ProfileRowView(label: "Age", value: "22", showChevron: false)
        Divider().overlay(Color(hex: "E6E6E6")).padding(.leading, 16)
        ProfileRowView(label: "Gender", value: "Male", showChevron: true)
    }
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .padding()
}
