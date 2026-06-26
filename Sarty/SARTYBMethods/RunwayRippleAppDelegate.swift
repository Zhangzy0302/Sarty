
import UIKit
import UserNotifications
import FBSDKCoreKit
import AdjustSdk

final class RunwayRippleAdjustManager: NSObject, AdjustDelegate {
    static let shared = RunwayRippleAdjustManager()

    private let runwayRippleInstallToken = "7q8l1k"
    private let runwayRipplePurchaseToken = "e0jqlh"
    private let runwayRippleAppToken = "jyro7rm7mcxs"
    private var runwayRippleDidInitialize = false

    private override init() {}

    func runwayRippleInitialize() {
        guard !runwayRippleDidInitialize else {
            return
        }

        guard let runwayRippleAdjustConfig = ADJConfig(
            appToken: runwayRippleAppToken,
            environment: ADJEnvironmentProduction
        ) else {
            return
        }

        runwayRippleAdjustConfig.logLevel = ADJLogLevel.verbose
        runwayRippleAdjustConfig.enableSendingInBackground()
        runwayRippleAdjustConfig.delegate = self
        
        print("ta_distinct_id: \(ClosetCharmBInfoStore.shared.closetCharmDeviceId)")

        Adjust.addGlobalCallbackParameter(
            ClosetCharmBInfoStore.shared.closetCharmDeviceId,
            forKey: "ta_distinct_id"
        )

        Adjust.attribution { [weak self] runwayRippleAttribution in
            self?.adjustAttributionChanged(runwayRippleAttribution)
        }

        Adjust.initSdk(runwayRippleAdjustConfig)
        runwayRippleDidInitialize = true
    }

    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        let runwayRippleInstallEvent = ADJEvent(eventToken: runwayRippleInstallToken)
        Adjust.trackEvent(runwayRippleInstallEvent)
    }

    func runwayRippleTrackPurchase(dollar: Double) {
        let runwayRipplePurchaseEvent = ADJEvent(eventToken: runwayRipplePurchaseToken)
        runwayRipplePurchaseEvent?.setRevenue(dollar, currency: "USD")
        Adjust.trackEvent(runwayRipplePurchaseEvent)
    }

    func runwayRippleTrackRechargeSuccess(dollar runwayRippleDollar: Double) {
        runwayRippleTrackPurchase(dollar: runwayRippleDollar)
        runwayRippleTrackFacebookPurchase(dollar: runwayRippleDollar)
    }

    private func runwayRippleTrackFacebookPurchase(dollar runwayRippleDollar: Double) {
        AppEvents.shared.logPurchase(
            amount: runwayRippleDollar,
            currency: "USD",
            parameters: [AppEvents.ParameterName(rawValue: "fb_mobile_purchase"): "true"]
        )
    }
}

class RunwayRippleAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        runwayRippleRegisterPush(application)

        return true
    }

    private func runwayRippleRegisterPush(_ application: UIApplication) {

        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in

            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        let runwayRipplePushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // 保存
        ClosetCharmAppStorage.closetCharmPushToken = runwayRipplePushToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Push 注册失败:", error)
    }
}
