import SwiftUI
import UIKit

struct ChicCanvasLocationPermissionDialog: View {
    let chicCanvasOpenSettingsAction: () -> Void
    let chicCanvasCancelAction: () -> Void

    init(
        chicCanvasOpenSettingsAction: @escaping () -> Void = ChicCanvasLocationPermissionDialog.chicCanvasOpenAppSettings,
        chicCanvasCancelAction: @escaping () -> Void
    ) {
        self.chicCanvasOpenSettingsAction = chicCanvasOpenSettingsAction
        self.chicCanvasCancelAction = chicCanvasCancelAction
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
                .onTapGesture {
                    chicCanvasCancelAction()
                }

            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Text("Enable Location")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk)

                    Text("Location helps tailor your runway\nexperience and unlock the best\nlocal style content.")
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
                    chicCanvasOpenSettingsAction()
                } label: {
                    Text("Open Settings")
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

    private static func chicCanvasOpenAppSettings() {
        guard let chicCanvasSettingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        Task { @MainActor in
            guard UIApplication.shared.canOpenURL(chicCanvasSettingsURL) else {
                return
            }

            await UIApplication.shared.open(chicCanvasSettingsURL)
        }
    }
}
