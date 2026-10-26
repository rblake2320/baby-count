import SwiftUI

struct TrailPoint {
    let position: CGPoint
    let time: Date
    let color: Color
}

/// A full-screen layer that draws a fading colorful trail under the baby's finger
/// and calls `onLift` when the finger comes off the screen.
struct TouchSurface: View {
    var onLift: () -> Void = {}

    @State private var points: [TrailPoint] = []
    @State private var lastLift = Date.distantPast
    @State private var step = 0

    private let trailColors: [Color] = [.white] + allColors.prefix(7).map(\.color)
    private let lifetime: TimeInterval = 1.0

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let now = Date()
                            step += 1
                            points.append(TrailPoint(position: value.location, time: now,
                                                     color: trailColors[(step / 3) % trailColors.count]))
                            points.removeAll { now.timeIntervalSince($0.time) > lifetime }
                        }
                        .onEnded { _ in
                            // Ignore lifts that come too fast, so wild tapping doesn't race ahead.
                            let now = Date()
                            guard now.timeIntervalSince(lastLift) > 0.6 else { return }
                            lastLift = now
                            onLift()
                        }
                )

            TimelineView(.animation) { timeline in
                Canvas { ctx, _ in
                    let now = timeline.date
                    for p in points {
                        let age = now.timeIntervalSince(p.time)
                        guard age < lifetime else { continue }
                        let fade = 1 - age / lifetime
                        let r = 18 + 22 * fade
                        let rect = CGRect(x: p.position.x - r, y: p.position.y - r, width: r * 2, height: r * 2)
                        ctx.opacity = fade
                        ctx.fill(Path(ellipseIn: rect), with: .color(p.color))
                        ctx.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.8)), lineWidth: 3)
                    }
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}
