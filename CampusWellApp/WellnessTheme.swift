//
//  WellnessTheme.swift
//  CampusWellApp
//
//  Created by isabel on 5/13/26.
//
// Allisson Amaya worked on this code
//
import SwiftUI
enum WellnessTheme {
    static let lavender = Color(red: 0.78, green: 0.72, blue: 0.95)
    static let softPurple = Color(red: 0.62, green: 0.52, blue: 0.92)
    static let deepPurple = Color(red: 0.42, green: 0.32, blue: 0.78)
    static let skyBlue = Color(red: 0.55, green: 0.75, blue: 0.98)
    static let calmBlue = Color(red: 0.35, green: 0.58, blue: 0.92)
    static let deepBlue = Color(red: 0.22, green: 0.42, blue: 0.78)
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.94, green: 0.91, blue: 0.99),
            Color(red: 0.88, green: 0.93, blue: 1.0),
            Color(red: 0.92, green: 0.95, blue: 1.0),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardBackground = Color.white.opacity(0.72)
    static func scaleColor(for value: Int, reversedStress: Bool = false) -> Color {
        let t = Double(value - 1) / 4.0
        let effective = reversedStress ? (1.0 - t) : t
        return Color(
            red: 0.35 + 0.25 * (1.0 - effective),
            green: 0.55 + 0.2 * effective,
            blue: 0.85 + 0.1 * (1.0 - effective)
        )
    }
}
struct WellnessCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(WellnessTheme.cardBackground)
                    .shadow(color: WellnessTheme.deepPurple.opacity(0.08), radius: 12, y: 4)
            )
    }
}

