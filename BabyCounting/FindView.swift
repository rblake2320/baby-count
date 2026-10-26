import SwiftUI

/// Find-it level: the app asks for a color or number and the baby taps a choice.
struct FindView: View {
    let category: Category
    let choices: Int
    let palette: [BabyColor]

    enum Kind: String { case color, number }

    struct Question: Equatable {
        let kind: Kind
        let answer: Int
        let options: [Int]
    }

    @State private var question: Question?
    @State private var wrongTries = 0
    @State private var shaking: Int?
    @State private var shakes: CGFloat = 0
    @State private var celebrating = false
    @State private var busy = false

    var body: some View {
        ZStack {
            cream.ignoresSafeArea()
            TouchSurface()

            if let q = question {
                VStack(spacing: 28) {
                    Button { ask() } label: {
                        Label(prompt(q), systemImage: "speaker.wave.2.fill")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(ink)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(.white))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Says the question again")

                    // Two rows when there are four choices, so the cards stay big.
                    let rows = q.options.count > 3
                        ? [Array(q.options.prefix(2)), Array(q.options.suffix(from: 2))]
                        : [q.options]
                    VStack(spacing: 20) {
                        ForEach(rows.indices, id: \.self) { r in
                            HStack(spacing: 20) {
                                ForEach(rows[r], id: \.self) { option in
                                    Button { pick(option) } label: { card(kind: q.kind, value: option) }
                                        .buttonStyle(.plain)
                                        .modifier(Shake(animatableData: shaking == option ? shakes : 0))
                                        .accessibilityLabel(name(kind: q.kind, value: option))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            if celebrating { Celebration() }
        }
        .onAppear { newQuestion() }
    }

    // MARK: Cards

    @ViewBuilder private func card(kind: Kind, value: Int) -> some View {
        switch kind {
        case .color:
            Circle()
                .fill(palette[value].color)
                .overlay(Circle().stroke(.white, lineWidth: 8))
                .overlay(Circle().stroke(.black.opacity(0.08), lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                .frame(maxWidth: 260, maxHeight: 260)
                .aspectRatio(1, contentMode: .fit)
        case .number:
            RoundedRectangle(cornerRadius: 36)
                .fill(.white)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .overlay(
                    Text("\(value + 1)")
                        .font(.system(size: 160, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.3)
                        .foregroundStyle(ink)
                        .padding(12)
                )
                .frame(maxWidth: 260, maxHeight: 260)
                .aspectRatio(1, contentMode: .fit)
        }
    }

    // MARK: Logic

    private func name(kind: Kind, value: Int) -> String {
        kind == .color ? palette[value].name : numberWords[value]
    }

    private func prompt(_ q: Question) -> String {
        "Where is \(name(kind: q.kind, value: q.answer))?"
    }

    private func newQuestion() {
        let kind: Kind
        switch category {
        case .colors: kind = .color
        case .numbers: kind = .number
        case .both: kind = Bool.random() ? .color : .number
        }
        let pool = Array(0..<(kind == .color ? palette.count : 10))

        // Avoid asking the same thing twice in a row.
        var answer = pool.randomElement()!
        if let last = question, last.kind == kind, pool.count > 1 {
            while answer == last.answer { answer = pool.randomElement()! }
        }
        let others = pool.filter { $0 != answer }.shuffled().prefix(max(1, min(choices, pool.count) - 1))
        question = Question(kind: kind, answer: answer, options: ([answer] + others).shuffled())
        wrongTries = 0
        ask()
    }

    private func ask() {
        guard let q = question else { return }
        Speaker.shared.say(prompt(q))
    }

    private func pick(_ option: Int) {
        guard let q = question, !busy else { return }
        if option == q.answer {
            busy = true
            ProgressStore.shared.record(Attempt(
                date: Date(),
                kind: q.kind.rawValue,
                target: name(kind: q.kind, value: q.answer),
                firstTry: wrongTries == 0,
                tries: wrongTries + 1,
                choices: q.options.count))
            Speaker.shared.say("Yes! \(name(kind: q.kind, value: option))! Good job!")
            withAnimation(.spring()) { celebrating = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                celebrating = false
                busy = false
                newQuestion()
            }
        } else {
            wrongTries += 1
            shaking = option
            withAnimation(.linear(duration: 0.4)) { shakes += 1 }
            Speaker.shared.say("That's \(name(kind: q.kind, value: option)). \(prompt(q))")
        }
    }
}

/// Side-to-side wobble for a wrong choice.
struct Shake: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 14 * sin(animatableData * .pi * 6), y: 0))
    }
}

/// Stars that burst across the screen after a right answer.
struct Celebration: View {
    private struct Star: Identifiable {
        let id = UUID()
        let x = CGFloat.random(in: 0.05...0.95)
        let y = CGFloat.random(in: 0.05...0.95)
        let size = CGFloat.random(in: 40...90)
        let color = (allColors.prefix(7).map(\.color) + [.white]).randomElement()!
        let spin = Double.random(in: -90...90)
    }

    @State private var stars = (0..<18).map { _ in Star() }
    @State private var shown = false

    var body: some View {
        GeometryReader { geo in
            ForEach(stars) { s in
                Image(systemName: "star.fill")
                    .font(.system(size: s.size))
                    .foregroundStyle(s.color)
                    .shadow(color: .black.opacity(0.25), radius: 3)
                    .rotationEffect(.degrees(shown ? s.spin : 0))
                    .scaleEffect(shown ? 1 : 0.1)
                    .position(x: s.x * geo.size.width, y: s.y * geo.size.height)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear { withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) { shown = true } }
    }
}
