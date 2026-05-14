//
//  SleepSupportView.swift
//  CampusWellApp
//
//  Created by isabel on 5/13/26.
//

// Isabel Morales worked on this code
import SwiftUI
struct SleepSupportView: View {
    @Environment(WellnessStore.self) private var store
    @State private var hours: Double = 7.5
    private let tips: [String] = [
        String(localized: "Keep a similar wake time on weekends — it stabilizes your body clock."),
        String(localized: "Dim screens an hour before bed or use Night Shift / reduced brightness."),
        String(localized: "Caffeine after mid-afternoon can still affect sleep for many people."),
        String(localized: "A short wind-down ritual (tea, stretch, journal) signals your brain to rest."),
        String(localized: "If you cannot sleep, get up for a few minutes instead of tossing for an hour."),
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    WellnessCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label(String(localized: "Last night’s sleep"), systemImage: "bed.double.fill")
                                .font(.headline)
                                .foregroundStyle(WellnessTheme.deepPurple)
                            Text(String(localized: "Log hours manually — most students know roughly how long they slept."))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text(String(localized: "Hours"))
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text(String(format: "%.1f", hours))
                                    .font(.title3.monospacedDigit().weight(.semibold))
                                    .foregroundStyle(WellnessTheme.calmBlue)
                            }
                            Slider(value: $hours, in: 0...12, step: 0.25)
                                .tint(WellnessTheme.calmBlue)
                            Button {
                                store.upsertSleepLog(hours: hours)
                            } label: {
                                Text(String(localized: "Save sleep log"))
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(WellnessTheme.calmBlue)
                        }
                    }
                    WellnessCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label(String(localized: "Target bedtime"), systemImage: "moon.stars.fill")
                                .font(.headline)
                                .foregroundStyle(WellnessTheme.deepBlue)
                            Text(String(localized: "Pair this with the “Sleep by target time” habit on the Today tab."))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker(
                                String(localized: "Target time"),
                                selection: Binding(
                                    get: { store.sleepTargetTime },
                                    set: { store.setSleepTarget($0) }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                            .tint(WellnessTheme.softPurple)
                        }
                    }
                    WellnessCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "Simple sleep tips"))
                                .font(.headline)
                                .foregroundStyle(WellnessTheme.softPurple)
                            ForEach(Array(tips.enumerated()), id: \.offset) { _, tip in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "leaf.fill")
                                        .foregroundStyle(WellnessTheme.skyBlue.opacity(0.9))
                                        .padding(.top, 2)
                                    Text(tip)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(WellnessTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle(String(localized: "Sleep"))
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let h = store.sleepHours(for: Date()) {
                    hours = h
                }
            }
        }
    }
}
#Preview {
    SleepSupportView()
        .environment(WellnessStore())
}
