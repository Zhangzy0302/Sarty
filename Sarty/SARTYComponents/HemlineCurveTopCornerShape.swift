import SwiftUI

struct HemlineCurveTopCornerShape: Shape {
    let hemlineCurveCornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let hemlineCurveRadius = min(hemlineCurveCornerRadius, min(rect.width, rect.height) / 2)
        var hemlineCurvePath = Path()

        hemlineCurvePath.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        hemlineCurvePath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + hemlineCurveRadius))
        hemlineCurvePath.addQuadCurve(
            to: CGPoint(x: rect.minX + hemlineCurveRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        hemlineCurvePath.addLine(to: CGPoint(x: rect.maxX - hemlineCurveRadius, y: rect.minY))
        hemlineCurvePath.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + hemlineCurveRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        hemlineCurvePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        hemlineCurvePath.closeSubpath()

        return hemlineCurvePath
    }
}
