import SwiftUI

private struct RunwaySlideBackGestureModifier: ViewModifier {
    @Environment(\.dismiss) private var runwaySlideDismiss

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            content

            Color.clear
                .frame(width: 28)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 18, coordinateSpace: .local)
                        .onEnded { runwaySlideValue in
                            let runwaySlideMovesRight = runwaySlideValue.translation.width > 86
                            let runwaySlideMostlyHorizontal = abs(runwaySlideValue.translation.height) < 70

                            if runwaySlideMovesRight && runwaySlideMostlyHorizontal {
                                runwaySlideDismiss()
                            }
                        }
                )
        }
    }
}

extension View {
    func runwaySlideBackGesture() -> some View {
        modifier(RunwaySlideBackGestureModifier())
    }
}
