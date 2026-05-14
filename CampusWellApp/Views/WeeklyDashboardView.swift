//
//  WeeklyDashboardView.swift
//  CampusWellApp
//
//  Created by isabel on 5/13/26.
//

// Jessica Reyes worked on this code.
import Charts
import SwiftUI
struct WeeklyDashboardView: View {
    @Environment(WellnessStore.self) private var store
    private var trend: [WeeklyTrendPoint] { store.weeklyTrendPoints() }
    private var moodPoints: [WeeklyTrendPoint] { trend.filter { $0.mood != nil } }
    private var stressPoints: [WeeklyTrendPoint] { trend.filter { $0.stress != nil } }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statsRow
                    WellnessCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "Check-in trends"))
                                .font(.headline)
                                .foregroundStyle(WellnessTheme.deepPurple)
                            Text(String(localized: "Mood and stress averages for this week (when you checked in)."))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if moodPoints.isEmpty && stressPoints.isEmpty {
                                ContentUnavailableView(
                                    String(localized: "No data yet"),
                                    systemImage: "chart.line.uptrend.xyaxis",
                                    description: Text(String(localized: "Complete a few daily check-ins to see your week at a glance."))
                                )
                                .frame(minHeight: 160)
                            } else {
                                Chart {
                                    ForEach(moodPoints) { p in
                                        if let m = p.mood {
                                            LineMark(
                                                x: .value(String(localized: "Day"), p.day),
                                                y: .value(String(localized: "Mood"), m)
                                            )
                                            .foregroundStyle(WellnessTheme.calmBlue)
                                            .interpolationMethod(.catmullRom)
                                        }
                                    }
                                    ForEach(stressPoints) { p in
                                        if let s = p.stress {
                                            LineMark(
                                                x: .value(String(localized: "Day"), p.day),
                                                y: .value(String(localized: "Stress"), s)
                                            )
                                            .foregroundStyle(WellnessTheme.softPurple)
                                            .interpolationMethod(.catmullRom)
                                        }
                                    }
                                }
                                .chartYScale(domain: 1...5)
                                .frame(height: 200)
                                HStack(spacing: 16) {
                                    legendDot(color: WellnessTheme.calmBlue, label: String(localized: "Mood"))
                                    legendDot(color: WellnessTheme.softPurple, label: String(localized: "Stress"))
                                }
                                .font(.caption)
                            }
                        }
                    }
                    WellnessCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "This week"))
                                .font(.headline)
                                .foregroundStyle(WellnessTheme.deepBlue)
                            let checkIns = store.checkIns.filter {
                                guard let start = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start,
                                      let end = Calendar.current.date(byAdding: .day, value: 7, to: start)
                                else { return false }
                                return $0.day >= start && $0.day < end
                            }.count
                            LabeledContent(String(localized: "Check-ins logged")) {
                                Text("\(checkIns)")
                                    .fontWeight(.semibold)
                            }
                            LabeledContent(String(localized: "Habit completions")) {
                                Text("\(store.completedHabitsThisWeek())")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(WellnessTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle(String(localized: "Progress"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(
                title: String(localized: "Streak"),
                value: "\(store.checkInStreak())",
                subtitle: String(localized: "days"),
                icon: "flame.fill",
                tint: WellnessTheme.softPurple
            )
            statTile(
                title: String(localized: "Habits"),
                value: "\(store.completedHabitsThisWeek())",
                subtitle: String(localized: "this week"),
                icon: "checkmark.seal.fill",
                tint: WellnessTheme.calmBlue
            )
        }
    }
    private func statTile(title: String, value: String, subtitle: String, icon: String, tint: Color) -> some View {
        WellnessCard {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title.weight(.bold))
                    .foregroundStyle(WellnessTheme.deepBlue)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}
#Preview {
    WeeklyDashboardView()
        .environment(WellnessStore())
}

