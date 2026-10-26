import SwiftUI
import Charts

/// One answered Find-it question.
struct Attempt: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let kind: String        // "color" or "number"
    let target: String      // e.g. "Red" or "Three"
    let firstTry: Bool      // right on the very first tap
    let tries: Int
    let choices: Int        // how many cards were shown
}

/// Saves Find-it results on this device only, in the app's own storage.
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()
    @Published private(set) var attempts: [Attempt] = []

    private let url: URL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("progress.json")

    private init() {
        if let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode([Attempt].self, from: data) {
            attempts = saved
        }
    }

    func record(_ attempt: Attempt) {
        attempts.append(attempt)
        save()
    }

    func reset() {
        attempts = []
        save()
    }

    private func save() {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        try? JSONEncoder().encode(attempts).write(to: url, options: .atomic)
    }
}

/// Parent-facing report of how Find-it is going.
struct ProgressScreen: View {
    @ObservedObject private var store = ProgressStore.shared
    @State private var confirmReset = false

    private struct DayStat: Identifiable {
        let day: Date
        let percent: Double
        let count: Int
        var id: Date { day }
    }

    private struct ItemStat: Identifiable {
        let name: String
        let right: Int
        let total: Int
        var id: String { name }
        var percent: Double { total == 0 ? 0 : Double(right) / Double(total) }
    }

    private var attempts: [Attempt] { store.attempts }

    private func firstTryPercent(_ list: [Attempt]) -> Double {
        list.isEmpty ? 0 : Double(list.filter(\.firstTry).count) / Double(list.count)
    }

    /// What random tapping would score, given how many choices were shown.
    private var guessPercent: Double {
        attempts.isEmpty ? 0 : attempts.map { 1 / Double($0.choices) }.reduce(0, +) / Double(attempts.count)
    }

    private var days: [DayStat] {
        let byDay = Dictionary(grouping: attempts) { Calendar.current.startOfDay(for: $0.date) }
        return byDay.map { DayStat(day: $0.key, percent: firstTryPercent($0.value), count: $0.value.count) }
            .sorted { $0.day < $1.day }
            .suffix(14)
    }

    private func items(kind: String) -> [ItemStat] {
        let order = kind == "color" ? allColors.map(\.name) : numberWords
        let byTarget = Dictionary(grouping: attempts.filter { $0.kind == kind }, by: \.target)
        return order.compactMap { name in
            guard let list = byTarget[name] else { return nil }
            return ItemStat(name: name, right: list.filter(\.firstTry).count, total: list.count)
        }
    }

    /// Compares the last 7 days with the 7 days before.
    private var weekChange: String? {
        let now = Date()
        let week: TimeInterval = 7 * 24 * 3600
        let thisWeek = attempts.filter { now.timeIntervalSince($0.date) < week }
        let lastWeek = attempts.filter { (week..<2 * week).contains(now.timeIntervalSince($0.date)) }
        guard thisWeek.count >= 5, lastWeek.count >= 5 else { return nil }
        let diff = Int(((firstTryPercent(thisWeek) - firstTryPercent(lastWeek)) * 100).rounded())
        if diff > 0 { return "Up \(diff) points from the week before." }
        if diff < 0 { return "Down \(-diff) points from the week before." }
        return "Same as the week before."
    }

    var body: some View {
        List {
            if attempts.isEmpty {
                Section {
                    Text("No results yet. Choose the Find it level and play. Every question your baby answers is saved here.")
                        .font(.callout)
                }
            } else {
                Section {
                    HStack {
                        tile("\(attempts.count)", "Questions")
                        tile(pct(firstTryPercent(attempts)), "Right first try")
                        tile(pct(guessPercent), "Guessing gets")
                    }
                    if let weekChange { Text(weekChange).font(.callout.bold()) }
                } header: {
                    Text("Overall")
                } footer: {
                    Text("A baby tapping at random is right about \(pct(guessPercent)) of the time. Scores well above that mean real learning.")
                }

                Section {
                    Chart {
                        ForEach(days) { d in
                            BarMark(x: .value("Day", d.day, unit: .day),
                                    y: .value("Right first try", d.percent * 100))
                                .foregroundStyle(Color.blue.gradient)
                        }
                        RuleMark(y: .value("Guessing", guessPercent * 100))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                            .foregroundStyle(.secondary)
                            .annotation(position: .top, alignment: .leading) {
                                Text("Guessing").font(.caption).foregroundStyle(.secondary)
                            }
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxis { AxisMarks(values: [0, 25, 50, 75, 100]) { v in
                        AxisGridLine(); AxisValueLabel { Text("\(v.as(Int.self) ?? 0)%") }
                    } }
                    .frame(height: 200)
                    .padding(.vertical, 8)
                } header: {
                    Text("Right on first try, by day")
                }

                let colorItems = items(kind: "color")
                if !colorItems.isEmpty {
                    Section("Colors") { ForEach(colorItems) { row($0, swatch: colorNamed($0.name)?.color) } }
                }
                let numberItems = items(kind: "number")
                if !numberItems.isEmpty {
                    Section("Numbers") { ForEach(numberItems) { row($0, swatch: nil) } }
                }

                Section {
                    Button("Reset progress", role: .destructive) { confirmReset = true }
                } footer: {
                    Text("Results are stored only on this device.")
                }
            }
        }
        .navigationTitle("Progress")
        .confirmationDialog("Erase all saved results?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Erase results", role: .destructive) { store.reset() }
        }
    }

    private func pct(_ value: Double) -> String { "\(Int((value * 100).rounded()))%" }

    private func tile(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold()).monospacedDigit()
            Text(label).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func row(_ item: ItemStat, swatch: Color?) -> some View {
        HStack(spacing: 12) {
            if let swatch {
                Circle().fill(swatch)
                    .overlay(Circle().stroke(.black.opacity(0.15)))
                    .frame(width: 26, height: 26)
            } else if let n = numberWords.firstIndex(of: item.name) {
                Text("\(n + 1)").font(.headline.bold()).frame(width: 26)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("\(item.right) of \(item.total) first try").foregroundStyle(.secondary).font(.callout)
                }
                ProgressView(value: item.percent)
                    .tint(item.percent >= 0.75 ? .green : item.percent >= 0.5 ? .orange : .red)
            }
        }
    }
}
