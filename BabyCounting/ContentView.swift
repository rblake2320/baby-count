import SwiftUI
import AVFoundation

struct BabyColor {
    let name: String
    let color: Color
}

let numberWords = ["One", "Two", "Three", "Four", "Five",
                   "Six", "Seven", "Eight", "Nine", "Ten"]

// The three primary colors, repeated as we count.
let primaryColors = [
    BabyColor(name: "Red", color: Color(red: 0.90, green: 0.10, blue: 0.10)),
    BabyColor(name: "Yellow", color: Color(red: 1.00, green: 0.85, blue: 0.00)),
    BabyColor(name: "Blue", color: Color(red: 0.10, green: 0.35, blue: 0.95)),
]

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
    @State private var index = 0          // 0...9
    @State private var bounce = false
    private let speaker = Speaker()

    private var number: Int { index + 1 }
    private var babyColor: BabyColor { primaryColors[index % primaryColors.count] }
    private var textColor: Color { babyColor.name == "Yellow" ? .black : .white }

    var body: some View {
        ZStack {
            babyColor.color.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("\(number)")
                    .font(.system(size: 220, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.3)
                    .scaleEffect(bounce ? 1.15 : 1.0)

                Text(numberWords[index])
                    .font(.system(size: 64, weight: .bold, design: .rounded))

                Text(babyColor.name)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .opacity(0.85)

                // One dot per number counted so far.
                HStack(spacing: 10) {
                    ForEach(0..<10, id: \.self) { i in
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
            }
            .foregroundStyle(textColor)
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture { next() }
        .onAppear { announce() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(numberWords[index]), \(babyColor.name)")
        .accessibilityHint("Double tap for the next number")
    }

    private func next() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            index = (index + 1) % 10
            bounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) { bounce = false }
        }
        announce()
    }

    private func announce() {
        speaker.say("\(numberWords[index])! \(babyColor.name)!")
    }
}

#Preview { ContentView() }
