//
//  WellnessStore.swift
//  CampusWellApp
//
//  Created by isabel on 5/13/26.
//
// Jessica Reyes worked on this code
//
import Foundation
@Observable
@MainActor
final class WellnessStore {
    private enum Keys {
        static let checkIns = "wellness.checkIns"
        static let sleepLogs = "wellness.sleepLogs"
        static let activeHabits = "wellness.activeHabits"
        static let habitCompletions = "wellness.habitCompletions"
        static let sleepTarget = "wellness.sleepTarget"
    }
    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    var checkIns: [DailyCheckIn] = []
    var sleepLogs: [SleepLogEntry] = []
    /// Habits the user chose to track
    var activeHabitKinds: Set<HabitKind> = Set([.drinkWater, .walk, .stretch])
    /// habit rawValue -> Set of start-of-day timestamps completed
    var habitCompletionsByDay: [String: Set<TimeInterval>] = [:]
    /// Target bedtime for "sleep by target" habit
    var sleepTargetTime: Date
    init() {
        let defaultHour = 22
        let defaultMinute = 30
        sleepTargetTime = Calendar.current.date(
            bySettingHour: defaultHour,
            minute: defaultMinute,
            second: 0,
            of: Date()
        ) ?? Date()
        load()
    }
    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    func dayKey(_ date: Date) -> String {
        let d = startOfDay(date)
        return String(d.timeIntervalSince1970)
    }
    func todayCheckIn() -> DailyCheckIn? {
        let t = startOfDay(Date())
        return checkIns.first { calendar.isDate($0.day, inSameDayAs: t) }
    }
    func upsertTodayCheckIn(mood: Int, energy: Int, stress: Int, sleepQuality: Int) {
        let t = startOfDay(Date())
        if let i = checkIns.firstIndex(where: { calendar.isDate($0.day, inSameDayAs: t) }) {
            checkIns[i].mood = mood
            checkIns[i].energy = energy
            checkIns[i].stress = stress
            checkIns[i].sleepQuality = sleepQuality
        } else {
            checkIns.append(DailyCheckIn(day: t, mood: mood, energy: energy, stress: stress, sleepQuality: sleepQuality))
        }
        save()
    }
    func isHabitCompleted(_ kind: HabitKind, on day: Date = Date()) -> Bool {
        let key = kind.rawValue
        let dayKey = self.dayKey(day)
        let intervals = habitCompletionsByDay[key] ?? []
        let start = startOfDay(day).timeIntervalSince1970
        return intervals.contains(start)
    }
    func toggleHabit(_ kind: HabitKind, on day: Date = Date()) {
        let key = kind.rawValue
        let start = startOfDay(day).timeIntervalSince1970
        var set = habitCompletionsByDay[key] ?? []
        if set.contains(start) {
            set.remove(start)
        } else {
            set.insert(start)
        }
        habitCompletionsByDay[key] = set
        save()
    }
    func upsertSleepLog(hours: Double, for day: Date = Date()) {
        let d = startOfDay(day)
        if let i = sleepLogs.firstIndex(where: { calendar.isDate($0.day, inSameDayAs: d) }) {
            sleepLogs[i].hoursSlept = hours
        } else {
            sleepLogs.append(SleepLogEntry(day: d, hoursSlept: hours))
        }
        save()
    }
    func sleepHours(for day: Date) -> Double? {
        let d = startOfDay(day)
        return sleepLogs.first { calendar.isDate($0.day, inSameDayAs: d) }?.hoursSlept
    }
    func checkInStreak() -> Int {
        let days = Set(checkIns.map { startOfDay($0.day) })
        guard !days.isEmpty else { return 0 }
        var streak = 0
        var cursor = startOfDay(Date())
        if !days.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
        }
        while days.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }
    func habitStreak(for kind: HabitKind) -> Int {
        let key = kind.rawValue
        let intervals = habitCompletionsByDay[key] ?? []
        let daySet = Set(intervals.map { Date(timeIntervalSince1970: $0) }.map { startOfDay($0) })
        guard !daySet.isEmpty else { return 0 }
        var streak = 0
        var cursor = startOfDay(Date())
        if !daySet.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
        }
        while daySet.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }
    func completedHabitsThisWeek() -> Int {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)
        else { return 0 }
        var count = 0
        for kind in activeHabitKinds {
            let key = kind.rawValue
            let intervals = habitCompletionsByDay[key] ?? []
            for ts in intervals {
                let day = Date(timeIntervalSince1970: ts)
                if day >= weekStart && day < weekEnd {
                    count += 1
                }
            }
        }
        return count
    }
    func weeklyTrendPoints() -> [WeeklyTrendPoint] {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }
        return (0..<7).compactMap { offset -> WeeklyTrendPoint? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
            let list = checkIns.filter { calendar.isDate($0.day, inSameDayAs: day) }
            guard !list.isEmpty else {
                return WeeklyTrendPoint(day: day, mood: nil, stress: nil)
            }
            let mood = Double(list.map(\.mood).reduce(0, +)) / Double(list.count)
            let stress = Double(list.map(\.stress).reduce(0, +)) / Double(list.count)
            return WeeklyTrendPoint(day: day, mood: mood, stress: stress)
        }
    }
    func setSleepTarget(_ date: Date) {
        sleepTargetTime = date
        save()
    }
    func toggleActiveHabit(_ kind: HabitKind) {
        if activeHabitKinds.contains(kind) {
            activeHabitKinds.remove(kind)
        } else {
            activeHabitKinds.insert(kind)
        }
        save()
    }
    func setHabitActive(_ kind: HabitKind, active: Bool) {
        if active {
            activeHabitKinds.insert(kind)
        } else {
            activeHabitKinds.remove(kind)
        }
        save()
    }
    private func load() {
        if let data = defaults.data(forKey: Keys.checkIns),
           let decoded = try? decoder.decode([DailyCheckIn].self, from: data) {
            checkIns = decoded
        }
        if let data = defaults.data(forKey: Keys.sleepLogs),
           let decoded = try? decoder.decode([SleepLogEntry].self, from: data) {
            sleepLogs = decoded
        }
        if let data = defaults.data(forKey: Keys.activeHabits),
           let raw = try? decoder.decode([String].self, from: data) {
            activeHabitKinds = Set(raw.compactMap { HabitKind(rawValue: $0) })
        }
        if let data = defaults.data(forKey: Keys.habitCompletions),
           let decoded = try? decoder.decode([String: Set<TimeInterval>].self, from: data) {
            habitCompletionsByDay = decoded
        }
        if let ts = defaults.object(forKey: Keys.sleepTarget) as? TimeInterval {
            sleepTargetTime = Date(timeIntervalSince1970: ts)
        }
    }
    private func save() {
        if let data = try? encoder.encode(checkIns) {
            defaults.set(data, forKey: Keys.checkIns)
        }
        if let data = try? encoder.encode(sleepLogs) {
            defaults.set(data, forKey: Keys.sleepLogs)
        }
        let raw = activeHabitKinds.map(\.rawValue)
        if let data = try? encoder.encode(raw) {
            defaults.set(data, forKey: Keys.activeHabits)
        }
        if let data = try? encoder.encode(habitCompletionsByDay) {
            defaults.set(data, forKey: Keys.habitCompletions)
        }
        defaults.set(sleepTargetTime.timeIntervalSince1970, forKey: Keys.sleepTarget)
    }
}
