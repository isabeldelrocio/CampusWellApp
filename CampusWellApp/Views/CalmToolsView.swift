//
//  CalmToolsView.swift
//  CampusWellApp
//
//  Created by isabel on 5/13/26.
//
// Allisson Amaya worked on this code.

import SwiftUI
import UIKit
struct CalmToolsView: View {
    @State private var showBreathing = false
    @State private var promptIndex = 0
    private let prompts: [String] = [
        String(localized: "You are allowed to move at your own pace."),
        String(localized: "One assignment at a time. Breathe between tasks."),
        String(localized: "Rest is part of studying — not the opposite of it."),
        String(localized: "It is okay to ask for help. That is what office hours are for."),
        String(localized: "Small breaks make your next focus block sharper."),
        String(localized: "You do not need to earn rest."),
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(String(localized: "Short tools for busy school days. Use them between classes or before exams."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    breathingCard
                    breakTimerCard
                    calmingCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(WellnessTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle(String(localized: "Calm"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showBreathing) {
                BreathingExerciseView()
            }
        }
    }
    private var breathingCard: some View {
        WellnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "Breathing"), systemImage: "wind")
                    .font(.headline)
                    .foregroundStyle(WellnessTheme.deepPurple)
                Text(String(localized: "Box breathing: four slow counts in, hold, out, hold — about two minutes."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button {
                    showBreathing = true
                } label: {
                    Text(String(localized: "Start breathing"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(WellnessTheme.calmBlue)
            }
        }
    }
    private var breakTimerCard: some View {
        WellnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "Break reminders"), systemImage: "cup.and.saucer.fill")
                    .font(.headline)
                    .foregroundStyle(WellnessTheme.calmBlue)
                Text(String(localized: "Set a gentle timer to stand, stretch, or step outside — no guilt needed."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                BreakTimerView()
            }
        }
    }
    private var calmingCard: some View {
        WellnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(String(localized: "Calming prompts"), systemImage: "text.quote")
                    .font(.headline)
                    .foregroundStyle(WellnessTheme.softPurple)
                Text(prompts[promptIndex % prompts.count])
                    .font(.body)
                    .foregroundStyle(WellnessTheme.deepBlue)
                    .frame(minHeight: 44, alignment: .topLeading)
                Button {
                    promptIndex = Int.random(in: 0..<prompts.count)
                } label: {
                    Text(String(localized: "New prompt"))
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(WellnessTheme.deepPurple)
            }
        }
    }
}
struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    enum Phase: String {
        case inhale
        case holdIn
        case exhale
        case holdOut
        var instruction: String {
            switch self {
            case .inhale: return String(localized: "Breathe in")
            case .holdIn: return String(localized: "Hold")
            case .exhale: return String(localized: "Breathe out")
            case .holdOut: return String(localized: "Hold")
            }
        }
        var next: Phase {
            switch self {
            case .inhale: return .holdIn
            case .holdIn: return .exhale
            case .exhale: return .holdOut
            case .holdOut: return .inhale
            }
        }
    }
    @State private var phase: Phase = .inhale
    @State private var scale: CGFloat = 0.85
    @State private var timerCancellable: Timer?
    var body: some View {
        NavigationStack {
            ZStack {
                WellnessTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 28) {
                    Text(phase.instruction)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(WellnessTheme.deepBlue)
                    Text(String(localized: "Follow the circle — about 4 seconds each step."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [WellnessTheme.lavender, WellnessTheme.skyBlue.opacity(0.6)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 140
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 3.8), value: scale)
                    Button(String(localized: "Done")) {
                        stopTimer()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WellnessTheme.calmBlue)
                }
                .padding()
            }
            .navigationTitle(String(localized: "Breathing"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { startTimer() }
            .onDisappear { stopTimer() }
        }
    }
    private func startTimer() {
        applyPhase(phase)
        timerCancellable = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            phase = phase.next
            applyPhase(phase)
        }
    }
    private func stopTimer() {
        timerCancellable?.invalidate()
        timerCancellable = nil
    }
    private func applyPhase(_ p: Phase) {
        switch p {
        case .inhale:
            scale = 1.12
        case .holdIn:
            scale = 1.12
        case .exhale:
            scale = 0.85
        case .holdOut:
            scale = 0.85
        }
    }
}
struct BreakTimerView: View {
    @State private var minutes: Int = 5
    @State private var remaining: Int?
    @State private var pendingWork: DispatchWorkItem?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker(String(localized: "Length"), selection: $minutes) {
                Text(String(localized: "5 min")).tag(5)
                Text(String(localized: "10 min")).tag(10)
                Text(String(localized: "15 min")).tag(15)
            }
            .pickerStyle(.segmented)
            if let r = remaining {
                Text(String(localized: "Time left: \(r / 60):\(String(format: "%02d", r % 60))"))
                    .font(.title3.monospacedDigit().weight(.medium))
                    .foregroundStyle(WellnessTheme.deepBlue)
            }
            HStack(spacing: 12) {
                if remaining == nil {
                    Button(String(localized: "Start break")) {
                        startCountdown()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WellnessTheme.softPurple)
                } else {
                    Button(String(localized: "Reset")) {
                        stopCountdown()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .onDisappear { stopCountdown() }
    }
    private func startCountdown() {
        stopCountdown()
        remaining = minutes * 60
        scheduleTick()
    }
    private func scheduleTick() {
        let work = DispatchWorkItem {
            guard let r = remaining else { return }
            if r <= 1 {
                remaining = nil
                pendingWork = nil
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } else {
                remaining = r - 1
                scheduleTick()
            }
        }
        pendingWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: work)
    }
    private func stopCountdown() {
        pendingWork?.cancel()
        pendingWork = nil
        remaining = nil
    }
}
#Preview {
    CalmToolsView()
}
