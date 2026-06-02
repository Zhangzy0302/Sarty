import SwiftUI

struct RunwayReportShieldDialog: View {
    let runwayReportAction: () -> Void
    let runwayShieldAction: () -> Void
    let runwayCancelAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    runwayCancelAction()
                }

            VStack(spacing: 16) {
                Button {
                    runwayReportAction()
                } label: {
                    Text("Report")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(LookbookShareColorStyle.styleCircleInk)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    runwayShieldAction()
                } label: {
                    Text("Shield")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 1.0, green: 0.31, blue: 0.22))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    runwayCancelAction()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(LookbookShareColorStyle.runwayGlowYellow)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
            }
            .padding(.horizontal, 48)
            .padding(.top, 28)
            .padding(.bottom, 48)
            .frame(maxWidth: .infinity)
            .background(
                HemlineCurveTopCornerShape(hemlineCurveCornerRadius: 24)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: LookbookShareColorStyle.runwayGlowYellow.opacity(0.9), location: 0),
                                .init(color: Color(red: 1.0, green: 0.94, blue: 0.70), location: 0.24),
                                .init(color: LookbookShareColorStyle.lookbookSoftCanvas, location: 0.62),
                                .init(color: LookbookShareColorStyle.lookbookSoftCanvas, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
        }
        .ignoresSafeArea()
        .transition(.opacity)
    }
}
