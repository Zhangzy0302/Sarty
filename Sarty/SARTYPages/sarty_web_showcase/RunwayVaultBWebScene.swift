import SwiftUI
import WebKit
import UIKit
import ScreenShield
import Combine

struct RunwayVaultBWebScene: View {
    let runwayVaultBWebUrlString: String

    @Environment(\.dismiss) private var runwayVaultBWebDismiss
    @StateObject private var runwayVaultBWebModel: RunwayVaultBWebModel

    init(runwayVaultBWebUrlString: String) {
        self.runwayVaultBWebUrlString = runwayVaultBWebUrlString
        _runwayVaultBWebModel = StateObject(
            wrappedValue: RunwayVaultBWebModel(runwayVaultBWebUrlString: runwayVaultBWebUrlString)
        )
    }

    var body: some View {
        ZStack {
            LookbookShareColorStyle.styleCircleInk
                .ignoresSafeArea()

            if runwayVaultBWebModel.runwayVaultBWebIsLoading {
                RunwayVaultBWebLaunchBackdrop()
            }

            runwayVaultBWebPageLayer

            if runwayVaultBWebModel.runwayVaultBWebIsLoading {
                RunwayVaultBWebLoadingLayer()
            }

            if let runwayVaultBWebLoadErrorText = runwayVaultBWebModel.runwayVaultBWebLoadErrorText {
                RunwayVaultBWebErrorLayer(
                    runwayVaultBWebErrorText: runwayVaultBWebLoadErrorText,
                    runwayVaultBWebRetryAction: runwayVaultBWebModel.runwayVaultBWebRetry
                )
            }

            if runwayVaultBWebModel.runwayVaultBWebIsScreenCaptured {
                RunwayVaultBWebScreenCaptureLayer()
            }
        }
        .protectScreenshot()
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            runwayVaultBWebModel.runwayVaultBWebSceneDidAppear()
        }
        .onDisappear {
            runwayVaultBWebModel.runwayVaultBWebSceneDidDisappear()
        }
    }

    @ViewBuilder
    private var runwayVaultBWebPageLayer: some View {
        if let runwayVaultBWebURL = runwayVaultBWebModel.runwayVaultBWebResolvedURL {
            RunwayVaultBWebContainer(
                runwayVaultBWebURL: runwayVaultBWebURL,
                runwayVaultBWebBridge: runwayVaultBWebModel.runwayVaultBWebBridge,
                runwayVaultBWebCallbacks: RunwayVaultBWebCallbacks(
                    runwayVaultBWebLoadingStarted: runwayVaultBWebModel.runwayVaultBWebLoadingStarted,
                    runwayVaultBWebLoadingFinished: runwayVaultBWebModel.runwayVaultBWebLoadingFinished,
                    runwayVaultBWebLoadingFailed: runwayVaultBWebModel.runwayVaultBWebLoadingFailed,
                    runwayVaultBWebCloseRequested: {
                        runwayVaultBWebModel.runwayVaultBWebCloseRequested()
                        runwayVaultBWebDismiss()
                    },
                    runwayVaultBWebRechargeRequested: runwayVaultBWebModel.runwayVaultBWebRechargeRequested,
                    runwayVaultBWebExternalOpenRequested: runwayVaultBWebModel.runwayVaultBWebOpenExternalURL
                )
            )
            .background(Color.clear)
            .ignoresSafeArea()
            .opacity(runwayVaultBWebModel.runwayVaultBWebIsLoading ? 0 : 1)
        } else {
            RunwayVaultBWebInvalidURLLayer(runwayVaultBWebUrlString: runwayVaultBWebUrlString)
        }
    }
}

@MainActor
private final class RunwayVaultBWebModel: ObservableObject {
    let runwayVaultBWebUrlString: String
    let runwayVaultBWebBridge = RunwayVaultBWebBridge()

    @Published var runwayVaultBWebIsLoading = true
    @Published var runwayVaultBWebLoadErrorText: String?
    @Published var runwayVaultBWebIsScreenCaptured = false

    private var runwayVaultBWebScreenCaptureObservation: NSKeyValueObservation?

    init(runwayVaultBWebUrlString: String) {
        self.runwayVaultBWebUrlString = runwayVaultBWebUrlString
    }

    var runwayVaultBWebResolvedURL: URL? {
        if let runwayVaultBWebDirectURL = URL(string: runwayVaultBWebUrlString),
           runwayVaultBWebDirectURL.scheme != nil {
            return runwayVaultBWebDirectURL
        }

        return URL(string: "https://\(runwayVaultBWebUrlString)")
    }

    func runwayVaultBWebSceneDidAppear() {
        RunwayVaultRechargeCenter.runwayVaultSilentlyPrepareStoreKitProducts()
        runwayVaultBWebStartScreenCaptureProtection()
    }

    func runwayVaultBWebSceneDidDisappear() {
        runwayVaultBWebStopScreenCaptureProtection()
    }

    func runwayVaultBWebLoadingStarted() {
        runwayVaultBWebLoadErrorText = nil
        runwayVaultBWebIsLoading = true
    }

    func runwayVaultBWebLoadingFinished(_ runwayVaultBWebDuration: Int) {
        runwayVaultBWebRecordLoadingDuration(runwayVaultBWebDuration)

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            runwayVaultBWebIsLoading = false
        }
    }

    func runwayVaultBWebLoadingFailed(_ runwayVaultBWebErrorText: String) {
        runwayVaultBWebIsLoading = false
        runwayVaultBWebLoadErrorText = runwayVaultBWebErrorText
    }

    func runwayVaultBWebRetry() {
        runwayVaultBWebLoadErrorText = nil
        runwayVaultBWebIsLoading = true
        runwayVaultBWebBridge.runwayVaultBWebReload()
    }

    func runwayVaultBWebCloseRequested() {
        ClosetCharmAppStorage.closetCharmUserToken = ""
    }

    func runwayVaultBWebRechargeRequested(orderCode runwayVaultBWebOrderCode: String, batchNo runwayVaultBWebBatchNo: String) {
        closetCharmUsersOrderCode = runwayVaultBWebOrderCode
        RunwaySignalHUDCenter.shared.runwaySignalShowLoading()

        Task { @MainActor in
            let runwayVaultBWebResult = await RunwayVaultRechargeCenter.runwayVaultPurchaseBPackage(
                productId: runwayVaultBWebBatchNo,
                orderCode: runwayVaultBWebOrderCode
            )
            RunwaySignalHUDCenter.shared.runwaySignalHideLoading()
            runwayVaultBWebHandleRechargeResult(
                runwayVaultBWebResult,
                batchNo: runwayVaultBWebBatchNo
            )
        }
    }

    func runwayVaultBWebOpenExternalURL(_ runwayVaultBWebUrlString: String) {
        guard let runwayVaultBWebURL = URL(string: runwayVaultBWebUrlString) else {
            runwayVaultBWebNotifyOpenState(state: "failed", urlString: runwayVaultBWebUrlString)
            return
        }

        UIApplication.shared.open(runwayVaultBWebURL, options: [:]) { [weak self] runwayVaultBWebSuccess in
            Task { @MainActor in
                self?.runwayVaultBWebNotifyOpenState(
                    state: runwayVaultBWebSuccess ? "success" : "failed",
                    urlString: runwayVaultBWebURL.absoluteString
                )
            }
        }
    }

    private func runwayVaultBWebHandleRechargeResult(
        _ runwayVaultBWebResult: RunwayVaultRechargeResult,
        batchNo runwayVaultBWebBatchNo: String
    ) {
        switch runwayVaultBWebResult {
        case .success:
            let runwayVaultBWebCoins = RunwayVaultRechargeCenter
                .runwayVaultPackage(for: runwayVaultBWebBatchNo)?
                .runwayVaultWardrobeValue ?? 0
            runwayVaultBWebNotifyRechargeState(state: "success", coins: runwayVaultBWebCoins)

        case .cancelled:
            return

        case .pending:
            runwayVaultBWebNotifyRechargeState(state: "pending")

        case let .failed(runwayVaultBWebMessage):
            RunwaySignalHUDCenter.shared.runwaySignalShowToast(runwayVaultBWebMessage, kind: .error)
            runwayVaultBWebNotifyRechargeState(state: "failed")
        }
    }

    private func runwayVaultBWebStartScreenCaptureProtection() {
        runwayVaultBWebIsScreenCaptured = UIScreen.main.isCaptured
        runwayVaultBWebScreenCaptureObservation = UIScreen.main.observe(
            \.isCaptured,
             options: [.new]
        ) { [weak self] _, runwayVaultBWebChange in
            let runwayVaultBWebCaptured = runwayVaultBWebChange.newValue ?? false
            Task { @MainActor in
                self?.runwayVaultBWebIsScreenCaptured = runwayVaultBWebCaptured
            }
        }
    }

    private func runwayVaultBWebStopScreenCaptureProtection() {
        runwayVaultBWebScreenCaptureObservation?.invalidate()
        runwayVaultBWebScreenCaptureObservation = nil
        runwayVaultBWebIsScreenCaptured = false
    }

    private func runwayVaultBWebRecordLoadingDuration(_ runwayVaultBWebDuration: Int) {
        Task {
            try? await TrendThreadApiCall().trendThreadLoadingTimeRecord(runwayVaultBWebDuration)
        }
    }

    private func runwayVaultBWebNotifyOpenState(state: String, urlString: String) {
        runwayVaultBWebBridge.runwayVaultBWebEvaluateJavaScript(
            runwayVaultBWebNativeOpenStateScript(state: state, urlString: urlString)
        )
    }

    private func runwayVaultBWebNotifyRechargeState(state: String, coins: Int = 0) {
        runwayVaultBWebBridge.runwayVaultBWebEvaluateJavaScript(
            runwayVaultBWebNativeRechargeStateScript(state: state, coins: coins)
        )
    }
}

private struct RunwayVaultBWebLaunchBackdrop: View {
    var body: some View {
        ZStack {
            Image("SARTY_guide_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.04),
                    LookbookShareColorStyle.styleCircleInk.opacity(0.28),
                    LookbookShareColorStyle.styleCircleInk.opacity(0.72),
                    LookbookShareColorStyle.styleCircleInk
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

private struct RunwayVaultBWebInvalidURLLayer: View {
    let runwayVaultBWebUrlString: String

    var body: some View {
        VStack(spacing: 12) {
            Text("Invalid URL")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(runwayVaultBWebUrlString)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct RunwayVaultBWebLoadingLayer: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.45)

            Text("Loading...")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
    }
}

private struct RunwayVaultBWebScreenCaptureLayer: View {
    var body: some View {
        ZStack {
            LookbookShareColorStyle.styleCircleInk
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text("Screen recording not allowed")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
        .zIndex(300)
    }
}

private struct RunwayVaultBWebErrorLayer: View {
    let runwayVaultBWebErrorText: String
    let runwayVaultBWebRetryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Load failed")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(runwayVaultBWebErrorText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)

            Button("Retry") {
                runwayVaultBWebRetryAction()
            }
            .buttonStyle(.plain)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(LookbookShareColorStyle.runwayGlowYellow)
            .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LookbookShareColorStyle.styleCircleInk.opacity(0.86))
    }
}

final class RunwayVaultBWebBridge: ObservableObject {
    weak var runwayVaultBWebView: WKWebView?

    func runwayVaultBWebReload() {
        runwayVaultBWebView?.reload()
    }

    func runwayVaultBWebEvaluateJavaScript(_ runwayVaultBWebJavaScript: String) {
        DispatchQueue.main.async { [weak self] in
            self?.runwayVaultBWebView?.evaluateJavaScript(runwayVaultBWebJavaScript)
        }
    }
}

private struct RunwayVaultBWebCallbacks {
    let runwayVaultBWebLoadingStarted: () -> Void
    let runwayVaultBWebLoadingFinished: (Int) -> Void
    let runwayVaultBWebLoadingFailed: (String) -> Void
    let runwayVaultBWebCloseRequested: () -> Void
    let runwayVaultBWebRechargeRequested: (_ orderCode: String, _ batchNo: String) -> Void
    let runwayVaultBWebExternalOpenRequested: (String) -> Void
}

private struct RunwayVaultBWebContainer: UIViewRepresentable {
    let runwayVaultBWebURL: URL
    let runwayVaultBWebBridge: RunwayVaultBWebBridge
    let runwayVaultBWebCallbacks: RunwayVaultBWebCallbacks

    func makeUIView(context: Context) -> WKWebView {
        let runwayVaultBWebConfiguration = WKWebViewConfiguration()
        let runwayVaultBWebContentController = WKUserContentController()
        RunwayVaultBWebBridgeAction.allCases.forEach {
            runwayVaultBWebContentController.add(context.coordinator, name: $0.rawValue)
        }
        runwayVaultBWebConfiguration.userContentController = runwayVaultBWebContentController
        runwayVaultBWebConfiguration.mediaTypesRequiringUserActionForPlayback = []
        runwayVaultBWebConfiguration.allowsInlineMediaPlayback = true

        let runwayVaultBWebView = WKWebView(frame: .zero, configuration: runwayVaultBWebConfiguration)
        runwayVaultBWebApplySettings(to: runwayVaultBWebView, coordinator: context.coordinator)
        runwayVaultBWebBridge.runwayVaultBWebView = runwayVaultBWebView
        runwayVaultBWebView.load(URLRequest(url: runwayVaultBWebURL))
        return runwayVaultBWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.runwayVaultBWebContainer = self
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        RunwayVaultBWebBridgeAction.allCases.forEach {
            uiView.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func runwayVaultBWebApplySettings(to runwayVaultBWebView: WKWebView, coordinator: Coordinator) {
        runwayVaultBWebView.navigationDelegate = coordinator
        runwayVaultBWebView.uiDelegate = coordinator
        runwayVaultBWebView.backgroundColor = .clear
        runwayVaultBWebView.isOpaque = false
        runwayVaultBWebView.scrollView.backgroundColor = .clear
        runwayVaultBWebView.scrollView.contentInsetAdjustmentBehavior = .never
        runwayVaultBWebView.scrollView.contentInset = .zero
        runwayVaultBWebView.scrollView.scrollIndicatorInsets = .zero
        runwayVaultBWebView.allowsBackForwardNavigationGestures = true
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        var runwayVaultBWebContainer: RunwayVaultBWebContainer
        var runwayVaultBWebStartTime: Date?

        init(_ runwayVaultBWebContainer: RunwayVaultBWebContainer) {
            self.runwayVaultBWebContainer = runwayVaultBWebContainer
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            runwayVaultBWebStartTime = Date()
            runwayVaultBWebContainer.runwayVaultBWebCallbacks.runwayVaultBWebLoadingStarted()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            runwayVaultBWebContainer.runwayVaultBWebCallbacks.runwayVaultBWebLoadingFinished(
                runwayVaultBWebElapsedMilliseconds()
            )
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            runwayVaultBWebContainer.runwayVaultBWebCallbacks.runwayVaultBWebLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            runwayVaultBWebContainer.runwayVaultBWebCallbacks.runwayVaultBWebLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let runwayVaultBWebURL = navigationAction.request.url,
                  let runwayVaultBWebScheme = runwayVaultBWebURL.scheme?.lowercased() else {
                decisionHandler(.allow)
                return
            }

            guard !RunwayVaultBWebNavigationPolicy.runwayVaultBWebShouldAllow(scheme: runwayVaultBWebScheme) else {
                decisionHandler(.allow)
                return
            }

            runwayVaultBWebOpenNonWebURL(runwayVaultBWebURL, webView: webView)
            decisionHandler(.cancel)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard let runwayVaultBWebURL = navigationAction.request.url else {
                return nil
            }

            if RunwayVaultBWebNavigationPolicy.runwayVaultBWebShouldOpenExternally(url: runwayVaultBWebURL) {
                UIApplication.shared.open(runwayVaultBWebURL)
                return nil
            }

            webView.load(URLRequest(url: runwayVaultBWebURL))
            return nil
        }

        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(.grant)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let runwayVaultBWebAction = RunwayVaultBWebBridgeAction(rawValue: message.name) else { return }

            switch runwayVaultBWebAction {
            case .rechargePay:
                guard let runwayVaultBWebOrder = RunwayVaultBWebOrder(body: message.body) else { return }
                runwayVaultBWebContainer.runwayVaultBWebCallbacks.runwayVaultBWebRechargeRequested(
                    runwayVaultBWebOrder.runwayVaultBWebOrderCode,
                    runwayVaultBWebOrder.runwayVaultBWebBatchNo
                )

            case .close:
                runwayVaultBWebContainer.runwayVaultBWebCallbacks.runwayVaultBWebCloseRequested()

            case .openBrowser:
                guard let runwayVaultBWebURLString = RunwayVaultBWebExternalLink.urlString(from: message.body) else { return }
                runwayVaultBWebContainer.runwayVaultBWebCallbacks.runwayVaultBWebExternalOpenRequested(runwayVaultBWebURLString)
            }
        }

        private func runwayVaultBWebElapsedMilliseconds() -> Int {
            runwayVaultBWebStartTime.map {
                Int(Date().timeIntervalSince($0) * 1000)
            } ?? 0
        }

        private func runwayVaultBWebOpenNonWebURL(_ runwayVaultBWebURL: URL, webView: WKWebView) {
            UIApplication.shared.open(runwayVaultBWebURL, options: [:]) { runwayVaultBWebSuccess in
                let runwayVaultBWebScript = runwayVaultBWebNativeOpenStateScript(
                    state: runwayVaultBWebSuccess ? "success" : "failed",
                    urlString: runwayVaultBWebURL.absoluteString
                )
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(runwayVaultBWebScript)
                }
            }
        }
    }
}

private enum RunwayVaultBWebBridgeAction: String, CaseIterable {
    case rechargePay
    case close = "Close"
    case openBrowser
}

private enum RunwayVaultBWebNavigationPolicy {
    static func runwayVaultBWebShouldAllow(scheme: String) -> Bool {
        ["http", "https", "file", "about"].contains(scheme)
    }

    static func runwayVaultBWebShouldOpenExternally(url runwayVaultBWebURL: URL) -> Bool {
        let runwayVaultBWebUrlString = runwayVaultBWebURL.absoluteString.lowercased()
        return runwayVaultBWebURL.scheme == "itms-apps"
            || runwayVaultBWebURL.scheme == "itms-services"
            || runwayVaultBWebUrlString.contains("apps.apple.com")
    }
}

private struct RunwayVaultBWebOrder {
    let runwayVaultBWebOrderCode: String
    let runwayVaultBWebBatchNo: String

    init?(body runwayVaultBWebBody: Any) {
        guard let runwayVaultBWebDict = runwayVaultBWebBody as? [String: Any],
              let runwayVaultBWebOrderCode = runwayVaultBWebDict["orderCode"] as? String,
              let runwayVaultBWebBatchNo = runwayVaultBWebDict["batchNo"] as? String else {
            return nil
        }

        self.runwayVaultBWebOrderCode = runwayVaultBWebOrderCode
        self.runwayVaultBWebBatchNo = runwayVaultBWebBatchNo
    }
}

private enum RunwayVaultBWebExternalLink {
    static func urlString(from runwayVaultBWebBody: Any) -> String? {
        if let runwayVaultBWebDict = runwayVaultBWebBody as? [String: Any],
           let runwayVaultBWebUrlString = runwayVaultBWebDict["url"] as? String {
            return runwayVaultBWebUrlString
        }

        return runwayVaultBWebBody as? String
    }
}

private func runwayVaultBWebNativeOpenStateScript(state: String, urlString: String) -> String {
    """
    window.dispatchEvent(new CustomEvent('nativeOpenState', {
        detail: { state: '\(state)', url: '\(urlString)' }
    }));
    """
}

private func runwayVaultBWebNativeRechargeStateScript(state: String, coins: Int) -> String {
    """
    window.dispatchEvent(new CustomEvent('nativeRechargeState', {
        detail: { state: '\(state)', coins: \(coins) }
    }));
    """
}
