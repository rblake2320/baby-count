import SwiftUI

/// A small button in the corner. It only opens settings after a long press,
/// so a baby tapping or swiping can't change anything.
struct ParentButton: View {
    let action: () -> Void
    @State private var pressing = false

    var body: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.black.opacity(0.35))
            .frame(width: 44, height: 44)
            .background(Circle().fill(.white.opacity(pressing ? 0.9 : 0.35)))
            .scaleEffect(pressing ? 1.3 : 1)
            .animation(.easeInOut(duration: 0.3), value: pressing)
            .onLongPressGesture(minimumDuration: 2) {
                action()
            } onPressingChanged: { pressing = $0 }
            .accessibilityLabel("Parent settings")
            .accessibilityHint("Press and hold for two seconds")
            .padding(12)
    }
}

struct ParentMenu: View {
    @Binding var category: Category
    @Binding var level: Level
    @Binding var choices: Int
    @Binding var moreColors: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var guidedAccessOn = UIAccessibility.isGuidedAccessEnabled

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        ProgressScreen()
                    } label: {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                }

                Section("Learn about") {
                    Picker("Learn about", selection: $category) {
                        ForEach(Category.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Picker("Level", selection: $level) {
                        ForEach(Level.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Level")
                } footer: {
                    Text(level.detail)
                }

                if category != .numbers {
                    Section {
                        Picker("Colors", selection: $moreColors) {
                            Text("3 main colors").tag(false)
                            Text("10 colors").tag(true)
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Colors")
                    } footer: {
                        Text(moreColors
                             ? "Red, yellow, blue, green, orange, purple, pink, brown, black, and white."
                             : "Red, yellow, and blue.")
                    }
                }

                if level == .find {
                    Section {
                        Picker("Choices", selection: $choices) {
                            Text("2").tag(2)
                            Text("3").tag(3)
                            Text("4").tag(4)
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Number of choices")
                    } footer: {
                        Text("Start with 2. Add more as your baby gets them right.")
                    }
                }

                Section {
                    Label(guidedAccessOn ? "Locked: Guided Access is on" : "Not locked right now",
                          systemImage: guidedAccessOn ? "lock.fill" : "lock.open")
                        .foregroundStyle(guidedAccessOn ? .green : .orange)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Apple's Guided Access keeps your baby inside this app. The Home screen, notifications, and other apps can't come up.")
                        Text("One-time setup: open Settings, then Accessibility, then Guided Access. Turn it on and set a passcode.")
                        Text("Each time: open Baby Count, triple-click the side button (or the Home button), then tap Start.")
                        Text("To leave: triple-click again and enter your passcode.")
                    }
                    .font(.callout)
                } header: {
                    Text("Lock the app")
                } footer: {
                    Text("Apple doesn't let apps lock themselves. Guided Access is the safe, built-in way.")
                }

                Section("Safety") {
                    Text("This app has no ads, no purchases, no links, and does not use the internet. It can't buy, order, or send anything.")
                        .font(.callout)
                }
            }
            .navigationTitle("Parent Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.guidedAccessStatusDidChangeNotification)) { _ in
            guidedAccessOn = UIAccessibility.isGuidedAccessEnabled
        }
    }
}
