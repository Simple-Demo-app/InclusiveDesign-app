import SwiftUI

@main struct App: SwiftUI.App {
    static let title = "Inclusive Design"

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    /// The elements that will be displayed in the grid
    @State var elements = [0]
    @State var tapCount = 0
    @State var hovering = 0

    @Environment(\.locale) var locale
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityInvertColors) var invertColors
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityShowButtonShapes) var showButtonShapes
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    var body: some View {
        GeometryReader(content: contentView(withGeometry:))
    }

    func aligning(_ elements: [Int], to size: Int) -> [Int] {
        var elements = elements
        while elements.count > size {
            let max = elements.max() // trim out the max item
            elements.removeAll(where: { $0 == max })
        }
        while elements.count < size { elements.append(elements.count) }
        return elements
    }

    func contentView(withGeometry proxy: GeometryProxy) -> some View {
        let size = proxy.size
        let (width, height) = (size.width, size.height)
        let buttonSize = 44 * buttonScale
        let (rows, columns) = (Int(floor(height / buttonSize)), Int(floor(width / buttonSize)))
        let (bwidth, bheight) = (height / .init(rows), width / .init(columns))
        let bspan = min(bwidth, bheight)

        func tapSpecial() {
            withAnimation(reduceMotion ? .none : .interpolatingSpring(mass: 1.0, stiffness: .init(1 + tapCount), damping: 0.4)) {
                elements = (0..<rows*columns).shuffled()
                tapCount += 1
            }
        }

        func hue(for index: Int) -> Color {
            Color(hue: .init(index) / .init(rows * columns), saturation: 1.0, brightness: hovering == index ? 1.0 : 0.9, opacity: index == 0 ? 1.0 : 0.5)
        }

        func button(at i: Int) -> some View {
            RoundedRectangle(cornerRadius: ((i == 0) ? bspan / 2.0 : 3))
                .fill((i == 0) == invertColors ? hue(for: i) : .accentColor)
            .onTapGesture(count: 1, perform: tapSpecial)
            .disabled(i != 0)
            .zIndex(i == 0 ? 1 : 0) // tappable always on top
            .help(i > 0 ? "Find the Circle among the Shapes" : "Keep tapping the Circle")
            .frame(width: bspan, height: bspan)
            .padding(.vertical, 2)
                .whenHovering { if $0 { self.hovering = i } }
        }

        return LazyVGrid(columns: Array(repeating: GridItem(.fixed(bwidth)), count: columns), alignment: .center, spacing: 0) {
            ForEach(aligning(elements, to: rows*columns), id: \.self, content: button(at:))
        }
    }

    private var buttonScale: CGFloat {
        switch sizeCategory {
        case .extraSmall: return 0.6
        case .small: return 0.8
        case .medium, .accessibilityMedium: return 1.0
        case .large, .accessibilityLarge: return 1.2
        case .extraLarge, .accessibilityExtraLarge: return 1.4
        case .extraExtraLarge, .accessibilityExtraExtraLarge: return 1.6
        case .extraExtraExtraLarge, .accessibilityExtraExtraExtraLarge: return 1.8
        @unknown default: return 1.0
        }
    }
}

extension View {
    /// Install a hover action on platforms that support it
    func whenHovering(perform action: @escaping (Bool) -> ()) -> some View {
        #if os(macOS) || os(iOS)
        return self.onHover(perform: action)
        #else
        return self
        #endif
    }
}
