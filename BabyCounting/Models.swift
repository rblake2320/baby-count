import SwiftUI
import AVFoundation

struct BabyColor: Equatable {
    let name: String
    let color: Color
    /// True for light colors, where dark text reads better.
    var darkText = false
}

let numberWords = ["One", "Two", "Three", "Four", "Five",
                   "Six", "Seven", "Eight", "Nine", "Ten"]

// The three primary colors.
let primaryColors = [
    BabyColor(name: "Red", color: Color(red: 0.90, green: 0.10, blue: 0.10)),
    BabyColor(name: "Yellow", color: Color(red: 1.00, green: 0.85, blue: 0.00), darkText: true),
    BabyColor(name: "Blue", color: Color(red: 0.10, green: 0.35, blue: 0.95)),
]

// Ten everyday colors, primaries first.
let allColors = primaryColors + [
    BabyColor(name: "Green", color: Color(red: 0.13, green: 0.65, blue: 0.25)),
    BabyColor(name: "Orange", color: Color(red: 1.00, green: 0.55, blue: 0.05), darkText: true),
    BabyColor(name: "Purple", color: Color(red: 0.55, green: 0.20, blue: 0.80)),
    BabyColor(name: "Pink", color: Color(red: 1.00, green: 0.55, blue: 0.75), darkText: true),
    BabyColor(name: "Brown", color: Color(red: 0.50, green: 0.30, blue: 0.15)),
    BabyColor(name: "Black", color: Color(red: 0.08, green: 0.08, blue: 0.08)),
    BabyColor(name: "White", color: .white, darkText: true),
]

func colorNamed(_ name: String) -> BabyColor? { allColors.first { $0.name == name } }

let cream = Color(red: 0.97, green: 0.96, blue: 0.93)
let ink = Color(red: 0.15, green: 0.15, blue: 0.20)

/// What the baby is learning.
enum Category: String, CaseIterable, Identifiable {
    case both = "Both"
    case numbers = "Numbers"
    case colors = "Colors"
    var id: String { rawValue }
}

/// How hard it is.
enum Level: String, CaseIterable, Identifiable {
    case learn = "Learn"
    case remember = "Remember"
    case find = "Find it"
    var id: String { rawValue }

    var detail: String {
        switch self {
        case .learn:
            return "Shows the word and says it right away."
        case .remember:
            return "No words on screen. The app waits a moment so your baby can try to remember, then says the answer."
        case .find:
            return "The app asks \"Where is red?\" and shows big choices. Tapping the right one gets a celebration. Results are saved in Progress."
        }
    }
}

/// Speaks words out loud. One shared instance so speech is never cut off by a view going away.
final class Speaker {
    static let shared = Speaker()
    private let synth = AVSpeechSynthesizer()

    private init() {
        // Play even when the silent switch is on.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func say(_ text: String, after delay: TimeInterval = 0) {
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.rate = 0.38
        u.pitchMultiplier = 1.2
        u.preUtteranceDelay = delay
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(u)
    }
}
