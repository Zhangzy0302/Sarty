import SwiftUI

struct VogueLaneRootNavPage: View {
    @State private var vogueLaneSelectedTab: VogueLaneNavTab = .home
    @State private var vogueLaneActiveRoute: VogueLaneWebRoute?
    @State private var vogueLaneReportShieldAction: VogueLaneReportShieldAction?
    @StateObject private var vogueLaneUserViewModel = ClosetProfileUserViewModel()
    @State private var vogueLaneShowsGuestLimitDialog = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                ChicFeedHomePage(
                    chicFeedPostRouteAction: {
                        vogueLaneOpenRoute(.postShowcase)
                    },
                    chicFeedAssistantRouteAction: {
                        vogueLaneOpenRoute(.assistantShowcase)
                    },
                    chicFeedPostDetailRouteAction: { vogueLanePostId in
                        vogueLaneOpenRoute(.picPostDetails(vogueLanePostId))
                    },
                    chicFeedCreatorRouteAction: { vogueLaneUserId in
                        vogueLaneOpenRoute(.profileAction("otherHome/\(vogueLaneUserId)"))
                    },
                    chicFeedMoreUserAction: { vogueLaneUserId, vogueLaneShieldAction in
                        vogueLaneShowReportShieldDialog(
                            userId: vogueLaneUserId,
                            shieldAction: vogueLaneShieldAction
                        )
                    },
                    chicFeedGuestLimitAction: {
                        vogueLaneShowGuestLimitDialog()
                    }
                )
                .vogueLaneTabVisible(vogueLaneSelectedTab == .home)

                ReelRadarDiscoverPage(
                    reelRadarPublishRouteAction: {
                        vogueLaneOpenRoute(.videoPostShowcase)
                    },
                    reelRadarVideoDetailRouteAction: { vogueLanePostId in
                        vogueLaneOpenRoute(.videoPostDetails(vogueLanePostId))
                    },
                    reelRadarMoreUserAction: { vogueLaneUserId, vogueLaneShieldAction in
                        vogueLaneShowReportShieldDialog(
                            userId: vogueLaneUserId,
                            shieldAction: vogueLaneShieldAction
                        )
                    }
                )
                .vogueLaneTabVisible(vogueLaneSelectedTab == .discover)

                ThreadTalkMessagePage(
                    threadTalkChatRouteAction: { vogueLaneChatId in
                        vogueLaneOpenRoute(.chatRoom(vogueLaneChatId))
                    }
                )
                .vogueLaneTabVisible(vogueLaneSelectedTab == .message)

                AtelierProfileMinePage(
                    atelierProfileWebRouteAction: { vogueLaneProfilePath in
                        vogueLaneOpenRoute(.profileAction(vogueLaneProfilePath))
                    }
                )
                    .vogueLaneTabVisible(vogueLaneSelectedTab == .mine)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VogueLaneBottomNavBar(vogueLaneSelectedTab: $vogueLaneSelectedTab)
                .ignoresSafeArea()

            NavigationLink(
                isActive: vogueLaneWebRouteBinding,
                destination: {
                    if let vogueLaneRoute = vogueLaneActiveRoute {
                        SilkBridgeWebScene(silkBridgeRoute: vogueLaneRoute.vogueLanePath)
                            .navigationBarHidden(true)
                    }
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()

            if vogueLaneReportShieldAction != nil {
                RunwayReportShieldDialog(
                    runwayReportAction: vogueLaneReportSelectedUser,
                    runwayShieldAction: vogueLaneShieldSelectedUser,
                    runwayCancelAction: vogueLaneDismissReportShieldDialog
                )
                .zIndex(30)
            }

            if vogueLaneShowsGuestLimitDialog {
                AtelierGuestLoginLimitDialog(
                    atelierGuestLoginAction: vogueLaneLoginFromGuestLimit,
                    atelierGuestCancelAction: vogueLaneDismissGuestLimitDialog
                )
                .zIndex(40)
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            SilkBridgeWebCanvas.silkBridgePreloadRootPageIfNeeded()
            vogueLaneUserViewModel.loadLoginClosetProfileUser()
        }
    }
}

private extension View {
    func vogueLaneTabVisible(_ vogueLaneIsVisible: Bool) -> some View {
        opacity(vogueLaneIsVisible ? 1 : 0)
            .allowsHitTesting(vogueLaneIsVisible)
            .accessibilityHidden(!vogueLaneIsVisible)
            .zIndex(vogueLaneIsVisible ? 1 : 0)
    }
}

private extension VogueLaneRootNavPage {
    func vogueLaneOpenRoute(_ route: VogueLaneWebRoute) {
        vogueLaneUserViewModel.loadLoginClosetProfileUser()
        guard !vogueLaneUserViewModel.isCurrentLoginUserGuestClosetProfile() || route.vogueLaneAllowsGuestVisit else {
            vogueLaneShowGuestLimitDialog()
            return
        }

        SilkBridgeWebCanvas.silkBridgePreloadRootPageIfNeeded()
        vogueLaneActiveRoute = route
    }

    func vogueLaneShowGuestLimitDialog() {
        withAnimation(.easeInOut(duration: 0.18)) {
            vogueLaneShowsGuestLimitDialog = true
        }
    }

    func vogueLaneDismissGuestLimitDialog() {
        withAnimation(.easeInOut(duration: 0.18)) {
            vogueLaneShowsGuestLimitDialog = false
        }
    }

    func vogueLaneLoginFromGuestLimit() {
        vogueLaneDismissGuestLimitDialog()
        vogueLaneUserViewModel.logoutClosetProfile()
    }

    func vogueLaneShowReportShieldDialog(userId: String, shieldAction: @escaping () -> Void) {
        vogueLaneUserViewModel.loadLoginClosetProfileUser()
        guard !vogueLaneUserViewModel.isCurrentLoginUserGuestClosetProfile() else {
            vogueLaneShowGuestLimitDialog()
            return
        }

        withAnimation(.easeInOut(duration: 0.18)) {
            vogueLaneReportShieldAction = VogueLaneReportShieldAction(
                vogueLaneUserId: userId,
                vogueLaneShieldAction: shieldAction
            )
        }
    }

    func vogueLaneDismissReportShieldDialog() {
        withAnimation(.easeInOut(duration: 0.18)) {
            vogueLaneReportShieldAction = nil
        }
    }

    func vogueLaneReportSelectedUser() {
        vogueLaneDismissReportShieldDialog()
        vogueLaneOpenRoute(.profileAction("report"))
    }

    func vogueLaneShieldSelectedUser() {
        let vogueLaneCurrentAction = vogueLaneReportShieldAction
        vogueLaneDismissReportShieldDialog()
        vogueLaneCurrentAction?.vogueLaneShieldAction()
    }

    var vogueLaneWebRouteBinding: Binding<Bool> {
        Binding(
            get: {
                vogueLaneActiveRoute != nil
            },
            set: { vogueLaneIsActive in
                if !vogueLaneIsActive {
                    vogueLaneActiveRoute = nil
                }
            }
        )
    }
}

private struct VogueLaneReportShieldAction: Identifiable {
    let id = UUID()
    let vogueLaneUserId: String
    let vogueLaneShieldAction: () -> Void
}

private enum VogueLaneWebRoute: Identifiable {
    case postShowcase
    case videoPostShowcase
    case assistantShowcase
    case picPostDetails(String)
    case videoPostDetails(String)
    case chatRoom(String)
    case profileAction(String)

    var id: String {
        switch self {
        case .postShowcase:
            "vogue_lane_post_showcase"
        case .videoPostShowcase:
            "vogue_lane_video_post_showcase"
        case .assistantShowcase:
            "vogue_lane_assistant_showcase"
        case .picPostDetails(let vogueLanePostId):
            "vogue_lane_pic_post_details_\(vogueLanePostId)"
        case .videoPostDetails(let vogueLanePostId):
            "vogue_lane_video_post_details_\(vogueLanePostId)"
        case .chatRoom(let vogueLaneChatId):
            "vogue_lane_chat_room_\(vogueLaneChatId)"
        case .profileAction(let vogueLaneProfilePath):
            "vogue_lane_profile_action_\(vogueLaneProfilePath)"
        }
    }

    var vogueLanePath: String {
        switch self {
        case .postShowcase:
            "publishPicPost"
        case .videoPostShowcase:
            "publishVideoPost"
        case .assistantShowcase:
            "aiDetails"
        case .picPostDetails(let vogueLanePostId):
            "picPostDetails/\(vogueLanePostId)"
        case .videoPostDetails(let vogueLanePostId):
            "videoPostDetails/\(vogueLanePostId)"
        case .chatRoom(let vogueLaneChatId):
            "chat/\(vogueLaneChatId)"
        case .profileAction(let vogueLaneProfilePath):
            vogueLaneProfilePath
        }
    }

    var vogueLaneAllowsGuestVisit: Bool {
        switch self {
        case .picPostDetails, .videoPostDetails:
            true
        case .postShowcase, .videoPostShowcase, .assistantShowcase, .chatRoom, .profileAction:
            false
        }
    }
}

private enum VogueLaneNavTab: CaseIterable {
    case home
    case discover
    case message
    case mine

    var vogueLaneIconName: String {
        switch self {
        case .home:
            "SARTY_nav_home"
        case .discover:
            "SARTY_nav_discover"
        case .message:
            "SARTY_nav_message"
        case .mine:
            "SARTY_nav_mine"
        }
    }
}

private struct VogueLaneBottomNavBar: View {
    @Binding var vogueLaneSelectedTab: VogueLaneNavTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(VogueLaneNavTab.allCases, id: \.self) { vogueLaneTab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vogueLaneSelectedTab = vogueLaneTab
                    }
                } label: {
                    Image(vogueLaneTab.vogueLaneIconName)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(
                            vogueLaneSelectedTab == vogueLaneTab
                            ? LookbookShareColorStyle.styleCircleInk
                            : Color.black.opacity(0.32)
                        )
                        .frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 40)
        .background(
            HemlineCurveTopCornerShape(hemlineCurveCornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 16, y: -4)
        )
        
    }
}
