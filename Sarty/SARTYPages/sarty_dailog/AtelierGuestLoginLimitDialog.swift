import SwiftUI

struct AtelierGuestLoginLimitDialog: View {
    let atelierGuestLoginAction: () -> Void
    let atelierGuestCancelAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
                .onTapGesture {
                    atelierGuestCancelAction()
                }

            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Text("Please Log In")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk)

                    Text("Log in now to unlock all features,\nview content and interact with\nothers.")
                        .font(.system(size: 15, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk.opacity(0.68))
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 26)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: LookbookShareColorStyle.runwayGlowYellow.opacity(0.88), location: 0),
                                    .init(color: Color.white, location: 0.26),
                                    .init(color: Color.white, location: 1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )

                Button {
                    atelierGuestLoginAction()
                } label: {
                    Text("Log In")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(LookbookShareColorStyle.runwayGlowYellow)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 42)
            }
            .padding(.horizontal, 43)
        }
        .transition(.opacity)
    }
}

#Preview {
    AtelierGuestLoginLimitDialog(
        atelierGuestLoginAction: {},
        atelierGuestCancelAction: {}
    )
}
