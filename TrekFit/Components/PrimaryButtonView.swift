import SwiftUI

struct PrimaryButtonView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity) // stretch to full available width
                .padding(.vertical, 16)
        }

        .background(Color("AccentOrange"))
        .clipShape(Capsule())
    }
}

#Preview {
    PrimaryButtonView(title: "Set Profile") {}
        .padding(.horizontal, 24)
}
