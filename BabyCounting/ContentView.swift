import SwiftUI
import AVFoundation

struct BabyColor {
    let name: String
    let color: Color
}

let numberWords = ["One", "Two", "Three", "Four", "Five",
                   "Six", "Seven", "Eight", "Nine", "Ten"]

// The three primary colors.
let primaryColors = [
    BabyColor(name: "Red", color: Color(red: 0.90, green: 0.10, blue: 0.10)),
    BabyColor(name: "Yellow", color: Color(red: 1.00, green: 0.85, blue: 0.00)),
    BabyColor(name: "Blue", color: Color(red: 0.10, green: 0.35, blue: 0.95)),
]

enum Mode: String, CaseIterable, Identifiable {
    case both = "Both"
    case numbers = "Numbers"
    case colors = "Colors"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .both: return "square.grid.2x2.fill"
        case .numbers: return "number"
        case .colors: return "paintpalette.fill"
        }
    }

    /// How many steps before it starts over.
    var count: Int { self == .colors ? primaryColors.count : 10 }
}

final class Speaker {
    private let synth = AVSpeechSynthesizer()

    init() {
        // Play even when the silent switch is on.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func say(_ text: String) {
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.rate = 0.38
        u.pitchMultiplier = 1.2
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(u)
    }
}

struct ContentView: View {
    @AppStorage("mode") private var mode: Mode = .both
    @State private var index = 0
    @State private var bounce = false
    private let speaker = Speaker()

    private var babyColor: BabyColor { primaryColors[index % primaryColors.count] }

    private var background: Color {
        mode == .numbers ? Color(red: 0.97, green: 0.96, blue: 0.93) : babyColor.color
    }

    private var textColor: Color {
        if mode == .numbers { return Color(red: 0.15, green: 0.15, blue: 0.2) }
        return babyColor.name == "Yellow" ? .black : .white
    }

    private var spoken: String {
        switch mode {
        case .both: return "\(numberWords[index])! \(babyColor.name)!"
        case .numbers: return "\(numberWords[index])!"
        case .colors: return "\(babyColor.name)!"
        }
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            // Tap anywhere to advance.
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture { next() }

            VStack(spacing: 24) {
                Spacer()
                mainContent
                    .scaleEffect(bounce ? 1.15 : 1.0)

                HStack(spacing: 10) {
                    ForEach(0..<mode.count, id: \.self) { i in
                        Circle()
                            .fill(textColor.opacity(i <= index ? 1 : 0.25))
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(.top, 12)

                Text("Tap anywhere")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .opacity(0.6)
                    .padding(.top, 8)
                Spacer()
            }
            .foregroundStyle(textColor)
            .padding()
            .allowsHitTesting(false)

            VStack {
                modePicker
                Spacer()
            }
        }
        .onAppear { announce() }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private var mainContent: some View {
        switch mode {
        case .both:
            VStack(spacing: 24) {
                bigNumber
                Text(numberWords[index])
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Text(babyColor.name)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .opacity(0.85)
            }
        case .numbers:
            VStack(spacing: 24) {
                bigNumber
                Text(numberWords[index])
                    .font(.system(size: 64, weight: .bold, design: .rounded))
            }
        case .colors:
            VStack(spacing: 32) {
                Circle()
                    .fill(.white.opacity(0.9))
                    .overlay(Circle().fill(babyColor.color).padding(18))
                    .frame(width: 260, height: 260)
                    .shadow(radius: 12)
                Text(babyColor.name)
                    .font(.system(size: 80, weight: .heavy, design: .rounded))
            }
        }
    }

    private var bigNumber: some View {
        Text("\(index + 1)")
            .font(.system(size: 220, weight: .heavy, design: .rounded))
            .minimumScaleFactor(0.3)
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(Mode.allCases) { m in
                Button {
                    mode = m
                    index = 0
                    announce()
                } label: {
                    Label(m.rawValue, systemImage: m.icon)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(mode == m ? Color.white : Color.white.opacity(0.35))
                        )
                        .foregroundStyle(Color.black.opacity(mode == m ? 0.9 : 0.6))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(mode == m ? .isSelected : [])
            }
        }
        .padding(6)
        .background(Capsule().fill(Color.black.opacity(0.12)))
        .padding(.top, 8)
    }

    private func next() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            index = (index + 1) % mode.count
            bounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) { bounce = false }
        }
        announce()
    }

    private func announce() {
        speaker.say(spoken)
    }
}

#Preview { ContentView() }
