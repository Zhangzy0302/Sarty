import SwiftUI
import WebKit

private enum SilkBridgeWebPlainKeys {
    static let webHost = "http://192.168.9.117:5173/"
    static let users = "users"
    static let posts = "posts"
    static let comments = "comments"
    static let chats = "chats"
    static let messages = "messages"
    static let toastMsg = "toastMsg"
    static let isShow = "isShow"
    static let isLogout = "isLogout"
    static let payKey = "payKey"
    static let avatar = "avator"
    static let name = "name"
    static let updateCurrentUser = "updateCurrentUser"

    static let emptyObject = "{}"

    static let currentUserVariable = "window.currentUser"
    static let userListVariable = "window.userList"
    static let postListVariable = "window.postList"
    static let commentListVariable = "window.commentList"
    static let chatListVariable = "window.chatList"
    static let messageListVariable = "window.messageList"
    static let otherVariable = "window.other"
}

@MainActor
private enum SilkBridgeWebRuntime {
    static let silkBridgeSharedProcessPool = WKProcessPool()
    static let silkBridgeSharedDataStore = WKWebsiteDataStore.default()
    static var silkBridgePreloadedWebView: WKWebView?
    static var silkBridgePreloadedURL: URL?

    static func silkBridgeRootURL() -> URL? {
        URL(string: SilkBridgeWebPlainKeys.webHost)
    }

    static func silkBridgePreloadRootPageIfNeeded() {
        guard let silkBridgeURL = silkBridgeRootURL() else { return }
        guard silkBridgePreloadedURL != silkBridgeURL else { return }

        let silkBridgeConfiguration = WKWebViewConfiguration()
        silkBridgeConfiguration.processPool = silkBridgeSharedProcessPool
        silkBridgeConfiguration.websiteDataStore = silkBridgeSharedDataStore
        silkBridgeConfiguration.allowsInlineMediaPlayback = true

        let silkBridgeWebView = WKWebView(frame: .zero, configuration: silkBridgeConfiguration)
        silkBridgeWebView.isHidden = true
        silkBridgeWebView.load(URLRequest(url: silkBridgeURL))

        silkBridgePreloadedWebView = silkBridgeWebView
        silkBridgePreloadedURL = silkBridgeURL
    }
}

struct SilkBridgeWebCanvas: UIViewRepresentable {
    let silkBridgeRoute: String
    let silkBridgeRegisterEmail: String?
    let silkBridgeRegisterPassword: String?

    @Environment(\.dismiss) private var silkBridgeDismiss

    static weak var silkBridgeCurrentWebView: WKWebView?

    func makeCoordinator() -> SilkBridgeWebCoordinator {
        SilkBridgeWebCoordinator(
            silkBridgeRegisterEmail: silkBridgeRegisterEmail,
            silkBridgeRegisterPassword: silkBridgeRegisterPassword,
            silkBridgeCloseHandler: { silkBridgeDismiss() }
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let silkBridgeMessageCenter = WKUserContentController()
        SilkBridgeWebCoordinator.SilkBridgeBridgeAction.allCases.forEach {
            silkBridgeMessageCenter.add(context.coordinator, name: $0.rawValue)
        }

        let silkBridgeWebConfiguration = WKWebViewConfiguration()
        silkBridgeWebConfiguration.userContentController = silkBridgeMessageCenter
        silkBridgeWebConfiguration.processPool = SilkBridgeWebRuntime.silkBridgeSharedProcessPool
        silkBridgeWebConfiguration.websiteDataStore = SilkBridgeWebRuntime.silkBridgeSharedDataStore
        silkBridgeWebConfiguration.allowsInlineMediaPlayback = true
        silkBridgeWebConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true

        let silkBridgeInitialScript = WKUserScript(
            source: context.coordinator.silkBridgeBuildInitialWardrobeScript(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        silkBridgeMessageCenter.addUserScript(silkBridgeInitialScript)

        let silkBridgeWebView = WKWebView(frame: .zero, configuration: silkBridgeWebConfiguration)
        silkBridgeWebView.uiDelegate = context.coordinator
        silkBridgeWebView.navigationDelegate = context.coordinator
        silkBridgeWebView.isOpaque = false
        silkBridgeWebView.backgroundColor = .clear
        silkBridgeWebView.scrollView.backgroundColor = .clear
        silkBridgeWebView.scrollView.contentInsetAdjustmentBehavior = .never
        silkBridgeWebView.scrollView.contentInset = .zero
        silkBridgeWebView.scrollView.isScrollEnabled = false
        silkBridgeWebView.scrollView.scrollIndicatorInsets = .zero
        silkBridgeWebView.allowsBackForwardNavigationGestures = true

        SilkBridgeWebCanvas.silkBridgeCurrentWebView = silkBridgeWebView
        silkBridgeLoadRoute(into: silkBridgeWebView)
        return silkBridgeWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: SilkBridgeWebCoordinator) {
        SilkBridgeWebCoordinator.SilkBridgeBridgeAction.allCases.forEach {
            uiView.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
    }

    static func silkBridgePreloadRootPageIfNeeded() {
        SilkBridgeWebRuntime.silkBridgePreloadRootPageIfNeeded()
    }

    private func silkBridgeLoadRoute(into webView: WKWebView) {
        guard let silkBridgeRootURL = SilkBridgeWebRuntime.silkBridgeRootURL() else { return }
        let silkBridgeTargetURL = silkBridgeRoute.isEmpty
            ? silkBridgeRootURL
            : URL(string: silkBridgeRoute, relativeTo: silkBridgeRootURL)?.absoluteURL

        guard let silkBridgeURL = silkBridgeTargetURL else { return }
        webView.load(URLRequest(url: silkBridgeURL))
    }
}

@MainActor
final class SilkBridgeWebCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    private let silkBridgeStorage = WardrobeShareStorageManager.shared
    private let silkBridgeRegisterEmail: String?
    private let silkBridgeRegisterPassword: String?
    private let silkBridgeCloseHandler: () -> Void

    init(
        silkBridgeRegisterEmail: String?,
        silkBridgeRegisterPassword: String?,
        silkBridgeCloseHandler: @escaping () -> Void
    ) {
        self.silkBridgeRegisterEmail = silkBridgeRegisterEmail
        self.silkBridgeRegisterPassword = silkBridgeRegisterPassword
        self.silkBridgeCloseHandler = silkBridgeCloseHandler
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(SilkBridgeWebPlainKeys.currentUserVariable) { _, _ in }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let silkBridgeAction = SilkBridgeBridgeAction(rawValue: message.name) else { return }
        silkBridgeHandleAction(silkBridgeAction, body: message.body)
    }
}

extension SilkBridgeWebCoordinator {
    enum SilkBridgeBridgeAction: String, CaseIterable {
        case close
        case userListUpdate
        case postsUpdate
        case commentsUpdate
        case chatsUpdate
        case messagesUpdate
        case logout
        case payment
        case newUserData
        case showToast
        case showLoading
        case showToLogin
    }

    private func silkBridgeHandleAction(_ silkBridgeAction: SilkBridgeBridgeAction, body: Any) {
        switch silkBridgeAction {
        case .close, .showToLogin:
            silkBridgeCloseHandler()

        case .userListUpdate:
            guard let silkBridgeUsers = silkBridgeExtractArray(body, key: SilkBridgeWebPlainKeys.users) else { return }
            silkBridgeStorage.wardrobeShareSaveUsers(ClosetProfileUser.fromJsonArray(silkBridgeUsers))

        case .postsUpdate:
            guard let silkBridgePosts = silkBridgeExtractArray(body, key: SilkBridgeWebPlainKeys.posts) else { return }
            silkBridgeStorage.wardrobeShareSaveWorks(LookbookPostVideo.fromJsonArray(silkBridgePosts))

        case .commentsUpdate:
            guard let silkBridgeComments = silkBridgeExtractArray(body, key: SilkBridgeWebPlainKeys.comments) else { return }
            silkBridgeStorage.wardrobeShareSaveComments(SocialThreadComment.fromJsonArray(silkBridgeComments))

        case .chatsUpdate:
            guard let silkBridgeRooms = silkBridgeExtractArray(body, key: SilkBridgeWebPlainKeys.chats) else { return }
            silkBridgeStorage.wardrobeShareSaveChatRooms(ClosetChatRoom.fromJsonArray(silkBridgeRooms))

        case .messagesUpdate:
            guard let silkBridgeMessages = silkBridgeExtractArray(body, key: SilkBridgeWebPlainKeys.messages) else { return }
            silkBridgeStorage.wardrobeShareSaveChatMessageList(ClosetChatMessage.fromJsonArray(silkBridgeMessages))

        case .logout:
            silkBridgeHandleLogout(body)

        case .payment:
            silkBridgeHandlePayment(body)

        case .newUserData:
            silkBridgeHandleRegistration(body)

        case .showToast:
            silkBridgeHandleToast(body)

        case .showLoading:
            silkBridgeHandleLoading(body)
        }
    }

    private func silkBridgeHandleToast(_ body: Any) {
        guard let silkBridgePayload = body as? [String: Any],
              let silkBridgeMessage = silkBridgePayload[SilkBridgeWebPlainKeys.toastMsg] as? String else {
            return
        }

        RunwaySignalHUDCenter.shared.runwaySignalShowToast(silkBridgeMessage, kind: .normal)
    }

    private func silkBridgeHandleLoading(_ body: Any) {
        guard let silkBridgePayload = body as? [String: Any],
              let silkBridgeShouldShow = silkBridgePayload[SilkBridgeWebPlainKeys.isShow] as? Bool else {
            return
        }

        if silkBridgeShouldShow {
            RunwaySignalHUDCenter.shared.runwaySignalShowLoading()
        } else {
            RunwaySignalHUDCenter.shared.runwaySignalHideLoading()
        }
    }

    private func silkBridgeHandleLogout(_ body: Any) {
        guard let silkBridgePayload = body as? [String: Any],
              let silkBridgeIsLogout = silkBridgePayload[SilkBridgeWebPlainKeys.isLogout] as? Bool else {
            return
        }

        if silkBridgeIsLogout {
            silkBridgeStorage.wardrobeShareRemoveCurrentUserAllWorks()
            silkBridgeStorage.wardrobeShareRemoveCurrentUserChatRooms()
            silkBridgeStorage.wardrobeShareRemoveCurrentUserAllComments()
            silkBridgeStorage.wardrobeShareMarkCurrentUserDeleted()
        }

        silkBridgeStorage.wardrobeShareSetCurrentUserId("")
        silkBridgeCloseHandler()
    }

    private func silkBridgeHandlePayment(_ body: Any) {
        guard let silkBridgePayload = body as? [String: Any],
              let silkBridgePayKey = silkBridgePayload[SilkBridgeWebPlainKeys.payKey] as? String else {
            RunwaySignalHUDCenter.shared.runwaySignalShowToast("Payment package unavailable", kind: .error)
            return
        }

        Task { [weak self] in
            guard let self else { return }

            let silkBridgeRechargeResult = await RunwayVaultRechargeCenter.runwayVaultPurchaseCurrentUser(
                productId: silkBridgePayKey,
                storage: silkBridgeStorage
            )

            switch silkBridgeRechargeResult {
            case .success:
                silkBridgeSyncCurrentUserToWeb()
                RunwaySignalHUDCenter.shared.runwaySignalShowToast("Recharge successful", kind: .success)

            case .cancelled:
                RunwaySignalHUDCenter.shared.runwaySignalShowToast("Payment cancelled", kind: .normal)

            case .pending:
                RunwaySignalHUDCenter.shared.runwaySignalShowToast("Purchase pending", kind: .normal)

            case .failed(let silkBridgeMessage):
                RunwaySignalHUDCenter.shared.runwaySignalShowToast(silkBridgeMessage, kind: .error)
                RunwayVaultRechargeCenter.runwayVaultSilentlyPrepareStoreKitProducts()
            }
        }
    }

    private func silkBridgeHandleRegistration(_ body: Any) {
        guard let silkBridgePayload = body as? [String: Any],
              let silkBridgeProfile = silkBridgePayload["newUserData"] as? [String: Any] else {
            return
        }

        let silkBridgeAvatar = silkBridgeProfile[SilkBridgeWebPlainKeys.avatar] as? String ?? ""
        let silkBridgeName = silkBridgeProfile[SilkBridgeWebPlainKeys.name] as? String ?? ""
        let silkBridgeFinalAvatar = silkBridgeAvatar.isEmpty
            ? "http://huanniuchat.oss-accelerate.aliyuncs.com/Orinx2026/ORINXDefaultAva.png"
            : silkBridgeAvatar

        guard !silkBridgeFinalAvatar.isEmpty else {
            RunwaySignalHUDCenter.shared.runwaySignalShowToast("Please upload avatar", kind: .error)
            return
        }

        guard !silkBridgeName.isEmpty else {
            RunwaySignalHUDCenter.shared.runwaySignalShowToast("Please enter name", kind: .error)
            return
        }

        guard let silkBridgeEmail = silkBridgeRegisterEmail,
              let silkBridgePassword = silkBridgeRegisterPassword else {
            return
        }

        let silkBridgeNewUser = ClosetProfileUser(
            closetProfileUserId: "\(Int(Date().timeIntervalSince1970))",
            closetProfileEmail: silkBridgeEmail,
            closetProfilePassword: silkBridgePassword,
            closetProfileUserName: silkBridgeName,
            closetProfileAvatar: silkBridgeFinalAvatar,
            closetProfileAboutMe: "",
            closetProfileFollowing: [],
            closetProfileFans: [],
            closetProfileBlacklist: [],
            closetProfileWalletBalance: 0,
            closetProfileLikePosts: [],
            closetProfileIsDeleted: 0,
            closetProfileIsGuest: 0
        )

        silkBridgeStorage.wardrobeShareAddUser(user: silkBridgeNewUser)
        silkBridgeStorage.wardrobeShareSetCurrentUserId(silkBridgeNewUser.closetProfileUserId)
        silkBridgeSyncCurrentUserToWeb()
        silkBridgeCloseHandler()
    }
}

extension SilkBridgeWebCoordinator {
    func silkBridgeSyncCurrentUserToWeb() {
        guard let silkBridgeCurrentUser = silkBridgeStorage.wardrobeShareGetUserById(
            userId: silkBridgeStorage.wardrobeShareGetCurrentUserId()
        ) else {
            return
        }

        let silkBridgeUserJSON = silkBridgeEncodeValue(
            silkBridgeCurrentUser.toClosetProfileTargetUser(),
            defaultValue: SilkBridgeWebPlainKeys.emptyObject
        )
        let silkBridgeEscapedJSON = silkBridgeUserJSON
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let silkBridgeUpdateScript =
            "\(SilkBridgeWebPlainKeys.updateCurrentUser)(JSON.parse(\"\(silkBridgeEscapedJSON)\"));"

        DispatchQueue.main.async {
            SilkBridgeWebCanvas.silkBridgeCurrentWebView?.evaluateJavaScript(silkBridgeUpdateScript) { _, _ in }
        }
    }

    private func silkBridgeExtractArray(_ body: Any, key: String) -> [[String: Any]]? {
        guard let silkBridgePayload = body as? [String: Any],
              let silkBridgeArray = silkBridgePayload[key] as? [[String: Any]] else {
            return nil
        }
        return silkBridgeArray
    }

    private func silkBridgeEncodeValue<T: Encodable>(
        _ value: T,
        defaultValue: String = "[]"
    ) -> String {
        let silkBridgeEncoder = JSONEncoder()
        silkBridgeEncoder.dateEncodingStrategy = .iso8601

        guard let silkBridgeData = try? silkBridgeEncoder.encode(value),
              let silkBridgeJSON = String(data: silkBridgeData, encoding: .utf8) else {
            return defaultValue
        }

        return silkBridgeJSON
    }

    private func silkBridgeEncodeAnyValue(_ value: Any) -> String {
        guard let silkBridgeData = try? JSONSerialization.data(withJSONObject: value),
              let silkBridgeJSON = String(data: silkBridgeData, encoding: .utf8) else {
            return SilkBridgeWebPlainKeys.emptyObject
        }

        return silkBridgeJSON
    }
}

extension SilkBridgeWebCoordinator {
    func silkBridgeBuildInitialWardrobeScript() -> String {
        let silkBridgeCurrentUser = silkBridgeStorage.wardrobeShareGetUserById(
            userId: silkBridgeStorage.wardrobeShareGetCurrentUserId()
        )

        let silkBridgeCurrentUserJSON = silkBridgeCurrentUser
            .map {
                silkBridgeEncodeValue(
                    $0.toClosetProfileTargetUser(),
                    defaultValue: SilkBridgeWebPlainKeys.emptyObject
                )
            }
            ?? SilkBridgeWebPlainKeys.emptyObject

        return """
            \(SilkBridgeWebPlainKeys.currentUserVariable) = JSON.parse('\(silkBridgeEscapeForJS(silkBridgeCurrentUserJSON))');
            \(SilkBridgeWebPlainKeys.userListVariable) = JSON.parse('\(silkBridgeEscapeForJS(silkBridgeEncodeValue(silkBridgeStorage.wardrobeShareGetUsers().map { $0.toClosetProfileTargetUser() })))');
            \(SilkBridgeWebPlainKeys.postListVariable) = JSON.parse('\(silkBridgeEscapeForJS(silkBridgeEncodeValue(silkBridgeStorage.wardrobeShareGetWorks().map { $0.toLookbookPostTargetItem() })))');
            \(SilkBridgeWebPlainKeys.commentListVariable) = JSON.parse('\(silkBridgeEscapeForJS(silkBridgeEncodeValue(silkBridgeStorage.wardrobeShareGetAllComments().map { $0.toSocialThreadTargetComment() })))');
            \(SilkBridgeWebPlainKeys.chatListVariable) = JSON.parse('\(silkBridgeEscapeForJS(silkBridgeEncodeValue(silkBridgeStorage.wardrobeShareGetChatRooms().map { $0.toClosetChatTargetRoom() })))');
            \(SilkBridgeWebPlainKeys.messageListVariable) = JSON.parse('\(silkBridgeEscapeForJS(silkBridgeEncodeValue(silkBridgeStorage.wardrobeShareGetAllMessages().map { $0.toClosetChatTargetMessage() })))');
            \(SilkBridgeWebPlainKeys.otherVariable) = \(silkBridgeBuildClosetConfig());
        """
    }

    private func silkBridgeEscapeForJS(_ json: String) -> String {
        json
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }

    private func silkBridgeBuildClosetConfig() -> String {
        let silkBridgeConfig: [String: Any] = [
            "postTheme": [
                "Formal",
                "Leisure",
                "Exquisite"
            ],
            "reportContent": [
                "Harassment",
                "Malicious fraud",
                "Pornography",
                "Malicious insults",
                "False Information"
            ],
            "coinsSetting": RunwayVaultRechargeCenter.runwayVaultPayloadCatalog()
        ]

        let silkBridgeConfigJSON = silkBridgeEncodeAnyValue(silkBridgeConfig)
        return "JSON.parse('\(silkBridgeEscapeForJS(silkBridgeConfigJSON))')"
    }
}

struct SilkBridgeWebScene: View {
    let silkBridgeRoute: String
    let silkBridgeRegisterEmail: String?
    let silkBridgeRegisterPassword: String?

    init(
        silkBridgeRoute: String = "",
        silkBridgeRegisterEmail: String? = nil,
        silkBridgeRegisterPassword: String? = nil
    ) {
        self.silkBridgeRoute = silkBridgeRoute
        self.silkBridgeRegisterEmail = silkBridgeRegisterEmail
        self.silkBridgeRegisterPassword = silkBridgeRegisterPassword
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    LookbookShareColorStyle.runwayGlowYellow.opacity(0.92),
                    LookbookShareColorStyle.lookbookSoftCanvas,
                    LookbookShareColorStyle.styleCircleInk.opacity(0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            SilkBridgeWebCanvas(
                silkBridgeRoute: silkBridgeRoute,
                silkBridgeRegisterEmail: silkBridgeRegisterEmail,
                silkBridgeRegisterPassword: silkBridgeRegisterPassword
            )
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .runwaySlideBackGesture()
        .runwaySignalHUDOverlay()
    }
}
