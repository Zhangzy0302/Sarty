
import SwiftUI
import UIKit

@main
struct SartyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var chicCanvasLocationManager = ChicCanvasLocationManager.shared
    @State private var chicCanvasIsCheckingLocationSettings = false

    @UIApplicationDelegateAdaptor(RunwayRippleAppDelegate.self)
    var appDelegate
    
    init() {
        Task {
            await ChicCanvasPhoneInfo.shared.chicCanvasGetPhoneInfo()
            RunwayRippleAdjustManager.shared.runwayRippleInitialize()
        }
        WardrobeShareStorageManager.shared.initializeAllDefaults()
        RunwayVaultRechargeCenter.runwayVaultSilentlyPrepareStoreKitProducts()
        SilkBridgeWebCanvas.silkBridgePreloadRootPageIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationView {
                    FashionGateRootPage()
                        .navigationBarHidden(true)
                        .runwaySignalHUDOverlay()
                }
                .navigationViewStyle(.stack)

                if chicCanvasLocationManager.chicCanvasShowLocationDialog {
                    ChicCanvasLocationPermissionDialog(
                        chicCanvasOpenSettingsAction: {
                            chicCanvasOpenLocationSettings()
                        },
                        chicCanvasCancelAction: {
                            chicCanvasIsCheckingLocationSettings = false
                            chicCanvasLocationManager.chicCanvasShowLocationDialog = false
                        }
                    )
                }
            }
            .onChange(of: scenePhase) { chicCanvasNewPhase in
                chicCanvasHandleScenePhaseChange(chicCanvasNewPhase)
            }
        }
    }

    private func chicCanvasOpenLocationSettings() {
        chicCanvasIsCheckingLocationSettings = true

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

    private func chicCanvasHandleScenePhaseChange(_ chicCanvasNewPhase: ScenePhase) {
        guard chicCanvasNewPhase == .active,
              chicCanvasIsCheckingLocationSettings else {
            return
        }

        chicCanvasLocationManager.chicCanvasShowLocationDialog = false
        chicCanvasIsCheckingLocationSettings = false
    }
}

private struct FashionGateRootPage: View {
    @AppStorage("wardrobeShareCurrentUserId") private var runwayWalkCurrentUserId = ""

    var body: some View {
        Group {
            if runwayWalkCurrentUserId.isEmpty {
                StyleCircleGuidePage()
            } else {
                VogueLaneRootNavPage()
            }
        }
        .onAppear {
            SilkBridgeWebCanvas.silkBridgePreloadRootPageIfNeeded()
        }
    }
}
