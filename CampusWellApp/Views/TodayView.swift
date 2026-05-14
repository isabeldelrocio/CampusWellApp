//
//  TodayView.swift
//  CampusWellApp
//
//  Created by isabel on 5/13/26.
//
// Allisson Amaya worked on this code.
import SwiftUI
struct TodayView: View {
    @Environment(WellnessStore.self) private var store
    @State private var mood = 3
    @State private var energy = 3
    @State private var stress = 3
    @State private var sleepQuality = 3
    @State private var showHabitPicker = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    checkInCard
                    habitsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(WellnessTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle(String(localized: "Today"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showHabitPicker = true
                    } label: {
                        Label(String(localized: "Choose habits"), systemImage: "slider.horizontal.3")
                    }
                    .tint(WellnessTheme.deepPurple)
                }
            }
            .onAppear(perform: syncFromStore)
            .sheet(isPresented: $showHabitPicker) {
                HabitPickerSheet()
            }
        }
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2.weight(.semibold))
                .foregroundStyle(WellnessTheme.deepBlue)
            Text(String(localized: "A quick check-in helps you notice patterns before exams pile up."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = String(localized: "there")
        if hour < 12 { return String(localized: "Good morning, \(name)") }
        if hour < 17 { return String(localized: "Good afternoon, \(name)") }
        return String(localized: "Good evening, \(name)")
    }
    private var checkInCard: some View {
        WellnessCard {
            VStack(alignment: .leading, spacing: 16) {
                Label(String(localized: "Daily check-in"), systemImage: "heart.text.square.fill")
                    .font(.headline)
                    .foregroundStyle(WellnessTheme.deepPurple)
                Text(String(localized: "Tap where you are right now — no wrong answers."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                fiveTapRow(title: String(localized: "Mood"), value: $mood, reversedStress: false)
                fiveTapRow(title: String(localized: "Energy"), value: $energy, reversedStress: false)
                fiveTapRow(title: String(localized: "Stress"), value: $stress, reversedStress: true)
                fiveTapRow(title: String(localized: "Sleep quality"), value: $sleepQuality, reversedStress: false)
                Button {
                    store.upsertTodayCheckIn(
                        mood: mood,
                        energy: energy,
                        stress: stress,
                        sleepQuality: sleepQuality
                    )
                } label: {
                    Text(String(localized: "Save check-in"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(WellnessTheme.calmBlue)
            }
        }
    }
    private func fiveTapRow(title: String, value: Binding<Int>, reversedStress: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { n in
                    Button {
                        value.wrappedValue = n
                    } label: {
                        Text("\(n)")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(value.wrappedValue == n
                                        ? WellnessTheme.scaleColor(for: n, reversedStress: reversedStress).opacity(0.35)
                                        : Color.primary.opacity(0.06))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    private var habitsSection: some View {
        WellnessCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(String(localized: "Habits"), systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(WellnessTheme.calmBlue)
                    Spacer()
                    Text(String(localized: "\(store.checkInStreak())-day check-in streak"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(WellnessTheme.deepPurple)
                }
                Text(String(localized: "Mark what you completed today."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if store.activeHabitKinds.isEmpty {
                    ContentUnavailableView(
                        String(localized: "No habits yet"),
                        systemImage: "tray",
                        description: Text(String(localized: "Tap the slider button to choose goals to track."))
                    )
                    .frame(minHeight: 120)
                } else {
                    ForEach(store.activeHabitKinds.sorted(by: { $0.rawValue < $1.rawValue })) { kind in
                        habitRow(kind)
                    }
                }
            }
        }
    }
    private func habitRow(_ kind: HabitKind) -> some View {
        let done = store.isHabitCompleted(kind)
        return Button {
            store.toggleHabit(kind)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: kind.symbolName)
                    .font(.title2)
                    .foregroundStyle(WellnessTheme.softPurple)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(kind.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(done ? WellnessTheme.calmBlue : .secondary.opacity(0.5))
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    private func syncFromStore() {
        if let c = store.todayCheckIn() {
            mood = c.mood
            energy = c.energy
            stress = c.stress
            sleepQuality = c.sleepQuality
        }
    }
}
struct HabitPickerSheet: View {
    @Environment(WellnessStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(String(localized: "Pick a few goals — small wins add up during the semester."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
                Section(String(localized: "Goals")) {
                    ForEach(HabitKind.allCases) { kind in
                        Toggle(isOn: Binding(
                            get: { store.activeHabitKinds.contains(kind) },
                            set: { store.setHabitActive(kind, active: $0) }
                        )) {
                            HStack(spacing: 12) {
                                Image(systemName: kind.symbolName)
                                    .foregroundStyle(WellnessTheme.softPurple)
                                VStack(alignment: .leading) {
                                    Text(kind.title)
                                    Text(kind.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .tint(WellnessTheme.calmBlue)
                    }
                }
            }
            .navigationTitle(String(localized: "Your habits"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
    }
}
#Preview {
    TodayView()
        .environment(WellnessStore())
}
