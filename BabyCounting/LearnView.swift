import SwiftUI

/// Learn and Remember levels: one number or color at a time, finger lift goes to the next.
struct LearnView: View {
    let category: Category
    let remember: Bool
    let palette: [BabyColor]

    @State private var index = 0
    @State private var bounce = false

    private var count: Int { category == .colors ? palette.count : 10 }
    private var babyColor: BabyColor { palette[index % palette.count] }

    private var background: Color { category == .numbers ? cream : babyColor.color }
    private var textColor: Color {
        if category == .numbers { return ink }
        return babyColor.darkText ? .black : .white
    }

    private var spoken: String {
        switch category {
        case .both: return "\(numberWords[index])! \(babyColor.name)!"
        case .numbers: return "\(numberWords[index])!"
        case .colors: return "\(babyColor.name)!"
        }
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            TouchSurface(onLift: next)

            VStack(spacing: 24) {
                content.scaleEffect(bounce ? 1.15 : 1.0)

                HStack(spacing: 10) {
                    ForEach(0..<count, id: \.self) { i in
                        Circle()
                            .fill(textColor.opacity(i <= index ? 1 : 0.25))
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(.top, 12)
            }
            .foregroundStyle(textColor)
            .padding()
            .allowsHitTesting(false)
        }
        .onAppear { announce() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(remember ? "Hidden word" : spoken)
        .accessibilityAddTraits(.allowsDirectInteraction)
    }

    @ViewBuilder private var content: some View {
        switch category {
        case .both:
            VStack(spacing: 24) {
                bigNumber
                if !remember {
                    word(numberWords[index], size: 64)
                    word(babyColor.name, size: 40).opacity(0.85)
                }
            }
        case .numbers:
            VStack(spacing: 24) {
                bigNumber
                if !remember { word(numberWords[index], size: 64) }
            }
        case .colors:
            VStack(spacing: 32) {
                Circle()
                    .fill(babyColor.name == "White" ? Color.black.opacity(0.15) : .white.opacity(0.9))
                    .overlay(Circle().fill(babyColor.color).padding(18))
                    .frame(width: 260, height: 260)
                    .shadow(radius: 12)
                if !remember { word(babyColor.name, size: 80) }
            }
        }
    }

    private var bigNumber: some View {
        Text("\(index + 1)")
            .font(.system(size: 220, weight: .heavy, design: .rounded))
            .minimumScaleFactor(0.3)
    }

    private func word(_ text: String, size: CGFloat) -> some View {
        Text(text).font(.system(size: size, weight: .bold, design: .rounded))
    }

    private func next() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            index = (index + 1) % count
            bounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) { bounce = false }
        }
        announce()
    }

    private func announce() {
        // In Remember, give the baby a moment before saying the answer.
        Speaker.shared.say(spoken, after: remember ? 2.5 : 0)
    }
}
