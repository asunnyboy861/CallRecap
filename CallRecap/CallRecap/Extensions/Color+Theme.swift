import SwiftUI

extension Color {
    static let appPrimary = Color.blue
    static let appSecondary = Color.gray.opacity(0.15)
    static let appAccent = Color.blue
    static let recordingRed = Color.red
    static let recordingRedLight = Color.red.opacity(0.15)
    static let successGreen = Color.green
    static let warningOrange = Color.orange
    static let sentimentPositive = Color.green
    static let sentimentNeutral = Color.gray
    static let sentimentNegative = Color.red
    static let sentimentMixed = Color.orange
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appPrimary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.headline)
    }
}
