import SwiftUI

struct ContentView: View {
    @AppStorage("mode") private var category: Category = .both
    @AppStorage("level") private var level: Level = .learn
    @AppStorage("choices") private var choices = 2
    @AppStorage("moreColors") private var moreColors = false
    @State private var showParent = false

    private var palette: [BabyColor] { moreColors ? allColors : primaryColors }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if level == .find {
                    FindView(category: category, choices: choices, palette: palette)
                } else {
                    LearnView(category: category, remember: level == .remember, palette: palette)
                }
            }
            // Start fresh whenever a setting changes.
            .id("\(category.rawValue)-\(level.rawValue)-\(choices)-\(moreColors)")

            ParentButton { showParent = true }
        }
        // Keep the baby in the app as much as iOS allows.
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .defersSystemGestures(on: .all)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        #if DEBUG
        // For screenshots in the simulator only: launch with -debugShowProgress YES.
        .sheet(isPresented: .constant(UserDefaults.standard.bool(forKey: "debugShowProgress"))) {
            NavigationStack { ProgressScreen() }
        }
        #endif
        .sheet(isPresented: $showParent) {
            ParentMenu(category: $category, level: $level, choices: $choices, moreColors: $moreColors)
        }
    }
}

#Preview { ContentView() }
