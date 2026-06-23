import SwiftUI

struct StyleCircleGuidePage: View {
    private let styleCirclePrimaryYellow = Color(red: 1.0, green: 0.74, blue: 0.03)
    private let styleCircleSoftWhite = Color.white.opacity(0.96)
    private let lookbookShareHorizontalPadding: CGFloat = 42
    @StateObject private var styleCircleUserViewModel = ClosetProfileUserViewModel()
    @State private var styleCircleShowsAuthPage = false
    @State private var styleCircleShowsHomePage = false
    @State private var styleCircleShowsEULA = false
    @State private var styleCirclePendingAction: StyleCircleGuideAction?
    @State private var styleCircleHasUserAgreement = ClosetConsentState.closetConsentAgree
    @State private var styleCircleAuthInitialMode: StyleCircleAuthMode = .signIn
    @State private var styleCirclePolicyRoute: StyleCirclePolicyRoute?
    @State private var runwayMomentGuideIsPreparingVisitorLogin = false
    @StateObject private var vogueVistaInitViewModel = VogueVistaInitViewModel()
    @State private var styleCircleDidStartVogueVistaInit = false
    @State private var styleCircleBWebRoute: StyleCircleBWebRoute?
    @State private var runwayMomentGuideIsPreparingQuickLogin = false

    var body: some View {
        ZStack {
            styleCircleGuideBackground

            switch vogueVistaInitViewModel.vogueVistaStatus {
            case .vogueVistaLoading:
                StyleCircleGuideLoadingView()
            case .vogueVistaA:
                styleCircleAPackageContent
            case .vogueVistaB:
                styleCircleBPackageContent
            }

            if styleCircleShowsEULA {
                RunwayConsentEULADialog(
                    runwayConsentCancelAction: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            styleCirclePendingAction = nil
                            styleCircleShowsEULA = false
                        }
                    },
                    runwayConsentAgreeAction: {
                        ClosetConsentState.closetConsentAgree = true
                        ClosetConsentState.closetConsentAgreeEULA = true
                        styleCircleHasUserAgreement = true
                        withAnimation(.easeInOut(duration: 0.18)) {
                            styleCircleShowsEULA = false
                        }
                        styleCircleRunPendingGuideAction()
                    }
                )
            }

            NavigationLink(
                isActive: $styleCircleShowsAuthPage,
                destination: {
                    StyleCircleAuthPage(styleCircleInitialMode: styleCircleAuthInitialMode)
                        .navigationBarHidden(true)
                        .runwaySignalHUDOverlay()
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()

            NavigationLink(
                isActive: $styleCircleShowsHomePage,
                destination: {
                    VogueLaneRootNavPage()
                        .navigationBarHidden(true)
                        .runwaySignalHUDOverlay()
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()

            NavigationLink(
                isActive: styleCirclePolicyRouteBinding,
                destination: {
                    if let styleCircleRoute = styleCirclePolicyRoute {
                        SilkBridgeWebScene(silkBridgeRoute: styleCircleRoute.streetStyleWebPath)
                            .navigationBarHidden(true)
                            .runwaySignalHUDOverlay()
                    }
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()

            NavigationLink(
                isActive: styleCircleBWebRouteBinding,
                destination: {
                    if let styleCircleBWebRoute {
                        RunwayVaultBWebScene(runwayVaultBWebUrlString: styleCircleBWebRoute.styleCircleURLString)
                            .navigationBarHidden(true)
                            .runwaySignalHUDOverlay()
                    }
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()
        }
        .onAppear {
            styleCircleHasUserAgreement = ClosetConsentState.closetConsentAgree
            styleCircleStartVogueVistaInitIfNeeded()
        }
        .navigationBarHidden(true)
    }
}

private enum StyleCircleGuideAction {
    case emailLogin
    case visitorLogin
}

private extension StyleCircleGuidePage {
    var styleCircleGuideBackground: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Image("SARTY_guide_bg")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .ignoresSafeArea()
                LinearGradient(
                    colors: [
                        LookbookShareColorStyle.lookbookSoftCanvas,
                        LookbookShareColorStyle.lookbookSoftCanvas.opacity(0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: geo.size.height / 2)
                .ignoresSafeArea()
            }
        }
    }

    var styleCircleAPackageContent: some View {
        VStack(spacing: 0) {
            Spacer()

            styleCircleLogo
                .padding(.bottom, 28)

            VStack(spacing: 18) {
                StyleCircleGuideButton(
                    lookbookShareTitle: "Login by email",
                    lookbookShareBackground: styleCirclePrimaryYellow,
                    lookbookShareForeground: .black,
                    lookbookShareAction: {
                        styleCircleHandleGuideAction(.emailLogin)
                    }
                )
                .disabled(runwayMomentGuideIsPreparingVisitorLogin)

                StyleCircleGuideButton(
                    lookbookShareTitle: "I'm new",
                    lookbookShareBackground: styleCircleSoftWhite,
                    lookbookShareForeground: .black,
                    lookbookShareAction: {
                        styleCircleHandleGuideAction(.visitorLogin)
                    }
                )
                .disabled(runwayMomentGuideIsPreparingVisitorLogin)
            }
            .padding(.horizontal, lookbookShareHorizontalPadding)
            .padding(.bottom, 26)

            StyleCircleSignUpLine(
                runwayMomentSignUpAction: {
                    styleCircleOpenAuthPage(.signUp)
                }
            )
            .padding(.bottom, 22)

            StyleCircleAgreementLine(
                styleCircleIsAgreed: $styleCircleHasUserAgreement,
                streetStyleUserAgreementAction: {
                    styleCirclePolicyRoute = StyleCirclePolicyRoute(streetStyleWebPath: "userAgreement")
                },
                streetStylePrivacyPolicyAction: {
                    styleCirclePolicyRoute = StyleCirclePolicyRoute(streetStyleWebPath: "privacyPolicy")
                }
            )
            .padding(.horizontal, 20)
        }
    }

    var styleCircleBPackageContent: some View {
        VStack(spacing: 0) {
            Spacer()

            styleCircleLogo
                .padding(.bottom, 32)

            StyleCircleGuideButton(
                lookbookShareTitle: runwayMomentGuideIsPreparingQuickLogin ? "Logging in..." : "Quick Login",
                lookbookShareBackground: styleCirclePrimaryYellow,
                lookbookShareForeground: .black,
                lookbookShareAction: {
                    styleCircleHandleQuickLogin()
                }
            )
            .disabled(runwayMomentGuideIsPreparingQuickLogin)
            .padding(.horizontal, lookbookShareHorizontalPadding)
            .padding(.bottom, 56)
        }
    }

    var styleCircleLogo: some View {
        Image("SARTY_app_logo")
            .resizable()
            .scaledToFit()
            .frame(width: 98, height: 98)
            .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    var styleCirclePolicyRouteBinding: Binding<Bool> {
        Binding(
            get: {
                styleCirclePolicyRoute != nil
            },
            set: { styleCircleIsActive in
                if !styleCircleIsActive {
                    styleCirclePolicyRoute = nil
                }
            }
        )
    }

    var styleCircleBWebRouteBinding: Binding<Bool> {
        Binding(
            get: {
                styleCircleBWebRoute != nil
            },
            set: { styleCircleIsActive in
                if !styleCircleIsActive {
                    styleCircleBWebRoute = nil
                }
            }
        )
    }

    var styleCircleHasAgreedAllConsent: Bool {
        ClosetConsentState.closetConsentAgree && ClosetConsentState.closetConsentAgreeEULA
    }

    func styleCircleHandleGuideAction(_ action: StyleCircleGuideAction) {
        guard !runwayMomentGuideIsPreparingVisitorLogin else { return }

        guard styleCircleHasAgreedAllConsent else {
            styleCirclePendingAction = action
            withAnimation(.easeInOut(duration: 0.18)) {
                styleCircleShowsEULA = true
            }
            return
        }

        styleCircleRunGuideAction(action)
    }

    func styleCircleRunPendingGuideAction() {
        guard let styleCirclePendingAction else { return }
        self.styleCirclePendingAction = nil
        styleCircleRunGuideAction(styleCirclePendingAction)
    }

    func styleCircleRunGuideAction(_ action: StyleCircleGuideAction) {
        switch action {
        case .emailLogin:
            styleCircleOpenAuthPage(.signIn)
        case .visitorLogin:
            styleCircleUserViewModel.visitorLoginClosetProfile()
            styleCircleShowDelayedVisitorLoadingThenNavigateHome()
        }
    }

    func styleCircleOpenAuthPage(_ styleCircleMode: StyleCircleAuthMode) {
        styleCircleAuthInitialMode = styleCircleMode
        styleCircleShowsAuthPage = true
    }

    func styleCircleShowDelayedVisitorLoadingThenNavigateHome() {
        runwayMomentGuideIsPreparingVisitorLogin = true
        RunwaySignalHUDCenter.shared.runwaySignalShowLoading()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            RunwaySignalHUDCenter.shared.runwaySignalHideLoading()
            styleCircleShowsHomePage = true
            runwayMomentGuideIsPreparingVisitorLogin = false
        }
    }

    func styleCircleStartVogueVistaInitIfNeeded() {
        guard !styleCircleDidStartVogueVistaInit else { return }
        styleCircleDidStartVogueVistaInit = true

        Task { @MainActor in
            await vogueVistaInitViewModel.vogueVistaInitFlow()
            styleCircleOpenBWebRoute(vogueVistaInitViewModel.vogueVistaNextRoute)
        }
    }

    func styleCircleHandleQuickLogin() {
        guard !runwayMomentGuideIsPreparingQuickLogin else { return }
        runwayMomentGuideIsPreparingQuickLogin = true
        RunwaySignalHUDCenter.shared.runwaySignalShowLoading()

        let styleCircleVogueVistaInitViewModel = vogueVistaInitViewModel

        Task { @MainActor in
            let styleCircleRoute: VogueVistaBRoute?
            if let vogueVistaNextRoute = styleCircleVogueVistaInitViewModel.vogueVistaNextRoute {
                styleCircleRoute = vogueVistaNextRoute
            } else {
                styleCircleRoute = await VogueVistaInitUtils.shared.vogueVistaGoLogin()
            }
            RunwaySignalHUDCenter.shared.runwaySignalHideLoading()
            runwayMomentGuideIsPreparingQuickLogin = false
            styleCircleOpenBWebRoute(styleCircleRoute)
        }
    }

    func styleCircleOpenBWebRoute(_ styleCircleRoute: VogueVistaBRoute?) {
        guard case let .some(.vogueVistaAgreement(vogueVistaURL)) = styleCircleRoute,
              !vogueVistaURL.isEmpty else {
            return
        }

        styleCircleBWebRoute = StyleCircleBWebRoute(styleCircleURLString: vogueVistaURL)
    }

}

private struct StyleCirclePolicyRoute: Identifiable {
    let id = UUID()
    let streetStyleWebPath: String
}

private struct StyleCircleBWebRoute: Identifiable {
    let id = UUID()
    let styleCircleURLString: String
}

private struct StyleCircleGuideButton: View {
    let lookbookShareTitle: String
    let lookbookShareBackground: Color
    let lookbookShareForeground: Color
    let lookbookShareAction: () -> Void

    var body: some View {
        Button {
            lookbookShareAction()
        } label: {
            Text(lookbookShareTitle)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(lookbookShareForeground)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(lookbookShareBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct StyleCircleGuideLoadingView: View {
    @State private var styleCircleOuterRingRotation = 0.0
    @State private var styleCircleInnerRingRotation = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("SARTY_app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 98, height: 98)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.black.opacity(0.14), radius: 16, y: 8)

            ZStack {
                StyleCircleGuideLoadingRing(
                    styleCircleColor: LookbookShareColorStyle.runwayGlowYellow,
                    styleCircleLineWidth: 5,
                    styleCircleStartAngle: -18,
                    styleCircleTrim: 0.68
                )
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(styleCircleOuterRingRotation))

                StyleCircleGuideLoadingRing(
                    styleCircleColor: LookbookShareColorStyle.styleCircleInk.opacity(0.72),
                    styleCircleLineWidth: 2.2,
                    styleCircleStartAngle: 150,
                    styleCircleTrim: 0.42
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(styleCircleInnerRingRotation))
            }
            .frame(width: 64, height: 64)
            .onAppear {
                withAnimation(.linear(duration: 1.05).repeatForever(autoreverses: false)) {
                    styleCircleOuterRingRotation = 360
                }
                withAnimation(.linear(duration: 1.25).repeatForever(autoreverses: false)) {
                    styleCircleInnerRingRotation = -360
                }
            }

            Text("Curating your feed")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(LookbookShareColorStyle.styleCircleInk)

        }.padding(.bottom, 100)
    }
}

private struct StyleCircleGuideLoadingRing: View {
    let styleCircleColor: Color
    let styleCircleLineWidth: CGFloat
    let styleCircleStartAngle: Double
    let styleCircleTrim: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: styleCircleTrim)
            .stroke(
                styleCircleColor,
                style: StrokeStyle(
                    lineWidth: styleCircleLineWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(styleCircleStartAngle))
    }
}

private struct StyleCircleSignUpLine: View {
    let runwayMomentSignUpAction: () -> Void

    var body: some View {
        HStack(spacing: 3) {
            Text("Don't have an account?")
                .foregroundStyle(.black.opacity(0.72))

            Button {
                runwayMomentSignUpAction()
            } label: {
                StyleCircleLinkText(styleCircleTitle: "Sign up")
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 12, weight: .regular))
    }
}

private struct StyleCircleAgreementLine: View {
    @Binding var styleCircleIsAgreed: Bool
    let streetStyleUserAgreementAction: () -> Void
    let streetStylePrivacyPolicyAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Button {
                styleCircleIsAgreed.toggle()
                ClosetConsentState.closetConsentAgree = styleCircleIsAgreed
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            styleCircleIsAgreed ? LookbookShareColorStyle.runwayGlowYellow : Color.black.opacity(0.35),
                            lineWidth: 1.2
                        )
                        .background(
                            Circle()
                                .fill(styleCircleIsAgreed ? LookbookShareColorStyle.runwayGlowYellow : Color.clear)
                        )

                    if styleCircleIsAgreed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    }
                }
                .frame(width: 12, height: 12)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 3) {
                Text("Agree with")
                    .foregroundStyle(.black.opacity(0.72))

                Button {
                    streetStyleUserAgreementAction()
                } label: {
                    StyleCircleLinkText(styleCircleTitle: "User Agreement")
                }
                .buttonStyle(.plain)

                Text("and")
                    .foregroundStyle(.black.opacity(0.72))

                Button {
                    streetStylePrivacyPolicyAction()
                } label: {
                    StyleCircleLinkText(styleCircleTitle: "Privacy Policy")
                }
                .buttonStyle(.plain)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
        .font(.system(size: 11, weight: .regular))
    }
}

private struct StyleCircleLinkText: View {
    let styleCircleTitle: String
    private let styleCircleLinkColor = Color(red: 1.0, green: 0.62, blue: 0.0)

    var body: some View {
        Text(styleCircleTitle)
            .foregroundStyle(styleCircleLinkColor)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(styleCircleLinkColor)
                    .frame(height: 0.6)
                    .offset(y: 2)
            }
    }
}
