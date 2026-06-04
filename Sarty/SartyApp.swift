//
//  SartyApp.swift
//  Sarty
//
//  Created by yangyang on 2026/5/27.
//

import SwiftUI

@main
struct SartyApp: App {
    init() {
        WardrobeShareStorageManager.shared.initializeAllDefaults()
        RunwayVaultRechargeCenter.runwayVaultSilentlyPrepareStoreKitProducts()
        SilkBridgeWebCanvas.silkBridgePreloadRootPageIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                FashionGateRootPage()
                    .navigationBarHidden(true)
                    .runwaySignalHUDOverlay()
            }
            .navigationViewStyle(.stack)
        }
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
