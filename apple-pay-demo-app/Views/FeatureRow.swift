import SwiftUI

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Theme.textColor.opacity(0.8)) 
                .frame(width: 40, height: 40)
                .background(Theme.textColor.opacity(0.15)) 
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textColor) 
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.secondaryTextColor) 
            }
            Spacer()
        }
    }
}

#Preview {
    FeatureRow(icon: "star.fill", title: "Sample Feature", subtitle: "This is a great feature.")
        .padding()
        .background(Theme.appBackgroundColor) 
        .preferredColorScheme(.dark)
}
