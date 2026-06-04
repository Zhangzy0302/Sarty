import SwiftUI

struct StyleCircleAuthPage: View {
    @Environment(\.dismiss) private var runwayMomentDismiss
    @State private var styleCircleAuthMode: StyleCircleAuthMode = .signIn
    @State private var closetChatEmailText = ""
    @State private var closetChatPasswordText = ""
    @State private var closetChatConfirmPasswordText = ""
    @State private var styleCircleShowsHomePage = false
    @State private var styleCircleRegistrationRoute: StyleCircleRegistrationRoute?
    @State private var runwayMomentAuthIsPreparingNavigation = false
    @StateObject private var styleCircleUserViewModel = ClosetProfileUserViewModel()
    @FocusState private var styleCircleFocusedField: StyleCircleAuthFocus?

    init(styleCircleInitialMode: StyleCircleAuthMode = .signIn) {
        _styleCircleAuthMode = State(initialValue: styleCircleInitialMode)
    }

    var body: some View {
        ZStack(alignment: .top) {
            StyleCircleAuthBackdrop()
                .contentShape(Rectangle())
                .onTapGesture {
                    styleCircleFocusedField = nil
                }

            VStack(alignment: .leading, spacing: 0) {
                StyleCircleAuthHeader(
                    styleCircleAuthMode: styleCircleAuthMode,
                    runwayMomentBackAction: {
                        if styleCircleAuthMode == .signIn {
                            runwayMomentDismiss()
                        } else {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                styleCircleAuthMode = .signIn
                            }
                        }
                    }
                )
                .padding(.top, 18)
                .padding(.bottom, 54)

                Text(styleCircleAuthMode.lookbookShareTitle)
                    .font(.system(size: styleCircleAuthMode == .forgotPassword ? 32 : 33, weight: .heavy))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.bottom, 68)

                VStack(alignment: .leading, spacing: 28) {
                    StyleCircleAuthField(
                        runwayMomentTitle: "Email",
                        runwayMomentPlaceholder: "Enter email address",
                        runwayMomentText: $closetChatEmailText,
                        runwayMomentFocus: $styleCircleFocusedField,
                        runwayMomentFocusValue: .email
                    )

                    StyleCirclePasswordBlock(
                        styleCircleAuthMode: styleCircleAuthMode,
                        closetChatPasswordText: $closetChatPasswordText,
                        closetChatConfirmPasswordText: $closetChatConfirmPasswordText,
                        styleCircleFocusedField: $styleCircleFocusedField,
                        runwayMomentForgotAction: {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                styleCircleAuthMode = .forgotPassword
                            }
                        }
                    )
                }

                Spacer(minLength: 50)

                Button {
                    styleCircleHandlePrimaryAction()
                } label: {
                    Text(styleCircleAuthMode.runwayMomentPrimaryTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(LookbookShareColorStyle.runwayGlowYellow)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(runwayMomentAuthIsPreparingNavigation)
                .padding(.horizontal, 73)
                .padding(.bottom, styleCircleAuthMode == .signIn ? 30 : 92)

                if styleCircleAuthMode == .signIn {
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            styleCircleAuthMode = .signUp
                        }
                    } label: {
                        Text("Sign up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.black.opacity(0.46))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(runwayMomentAuthIsPreparingNavigation)
                    .padding(.bottom, 92)
                }
            }
            .padding(.horizontal, 28)
        }
        .ignoresSafeArea(.keyboard)
        .runwaySignalHUDOverlay()
        .navigationBarHidden(true)
        .runwaySlideBackGesture()
        .background(
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
        )
        .background(
            NavigationLink(
                isActive: styleCircleRegistrationRouteBinding,
                destination: {
                    if let styleCircleRoute = styleCircleRegistrationRoute {
                        SilkBridgeWebScene(
                            silkBridgeRoute: styleCircleRoute.styleCircleWebPath,
                            silkBridgeRegisterEmail: styleCircleRoute.styleCircleEmail,
                            silkBridgeRegisterPassword: styleCircleRoute.styleCirclePassword
                        )
                        .navigationBarHidden(true)
                    }
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()
        )
    }
}

private extension StyleCircleAuthPage {
    var styleCircleRegistrationRouteBinding: Binding<Bool> {
        Binding(
            get: {
                styleCircleRegistrationRoute != nil
            },
            set: { styleCircleIsActive in
                if !styleCircleIsActive {
                    styleCircleRegistrationRoute = nil
                    styleCircleHandleRegistrationDismiss()
                }
            }
        )
    }

    func styleCircleHandlePrimaryAction() {
        guard !runwayMomentAuthIsPreparingNavigation else { return }
        styleCircleFocusedField = nil

        switch styleCircleAuthMode {
        case .signIn:
            styleCircleHandleLogin()
        case .signUp:
            styleCircleHandleRegisterStart()
        case .forgotPassword:
            styleCircleShowToast("Please sign in or create a new account")
            withAnimation(.easeInOut(duration: 0.22)) {
                styleCircleAuthMode = .signIn
            }
        }
    }

    func styleCircleHandleLogin() {
        let styleCircleEmail = closetChatEmailText.trimmingCharacters(in: .whitespacesAndNewlines)
        let styleCirclePassword = closetChatPasswordText

        guard styleCircleIsValidEmail(styleCircleEmail) else {
            styleCircleShowToast("Please enter a valid email")
            return
        }

        guard !styleCirclePassword.isEmpty else {
            styleCircleShowToast("Please enter password")
            return
        }

        guard styleCircleUserViewModel.loginByEmailAndPasswordClosetProfile(
            email: styleCircleEmail,
            password: styleCirclePassword
        ) != nil else {
            styleCircleShowToast("Email or password is incorrect")
            return
        }

        styleCircleShowDelayedLoadingThenNavigateHome()
    }

    func styleCircleHandleRegisterStart() {
        let styleCircleEmail = closetChatEmailText.trimmingCharacters(in: .whitespacesAndNewlines)
        let styleCirclePassword = closetChatPasswordText
        let styleCircleConfirmPassword = closetChatConfirmPasswordText

        guard !styleCircleEmail.isEmpty else {
            styleCircleShowToast("Please enter email")
            return
        }

        guard !styleCirclePassword.isEmpty else {
            styleCircleShowToast("Please enter password")
            return
        }

        guard !styleCircleConfirmPassword.isEmpty else {
            styleCircleShowToast("Please enter the password again")
            return
        }

        guard styleCirclePassword == styleCircleConfirmPassword else {
            styleCircleShowToast("Passwords do not match")
            return
        }

        let styleCircleUsers = WardrobeShareStorageManager.shared.wardrobeShareGetUsers()
        guard !styleCircleUsers.contains(where: { $0.closetProfileEmail == styleCircleEmail && $0.closetProfileIsDeleted == 0 }) else {
            styleCircleShowToast("This email is already registered")
            return
        }

        styleCircleShowDelayedLoadingThenNavigateRegister(
            styleCircleEmail: styleCircleEmail,
            styleCirclePassword: styleCirclePassword
        )
    }

    func styleCircleHandleRegistrationDismiss() {
        let styleCircleCurrentUserId = WardrobeShareStorageManager.shared.wardrobeShareGetCurrentUserId()
        guard !styleCircleCurrentUserId.isEmpty else { return }
        styleCircleShowsHomePage = true
    }

    func styleCircleShowDelayedLoadingThenNavigateHome() {
        runwayMomentAuthIsPreparingNavigation = true
        RunwaySignalHUDCenter.shared.runwaySignalShowLoading()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            RunwaySignalHUDCenter.shared.runwaySignalHideLoading()
            styleCircleShowsHomePage = true
            runwayMomentAuthIsPreparingNavigation = false
        }
    }

    func styleCircleShowDelayedLoadingThenNavigateRegister(
        styleCircleEmail: String,
        styleCirclePassword: String
    ) {
        runwayMomentAuthIsPreparingNavigation = true
        RunwaySignalHUDCenter.shared.runwaySignalShowLoading()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            RunwaySignalHUDCenter.shared.runwaySignalHideLoading()
            styleCircleRegistrationRoute = StyleCircleRegistrationRoute(
                styleCircleEmail: styleCircleEmail,
                styleCirclePassword: styleCirclePassword
            )
            runwayMomentAuthIsPreparingNavigation = false
        }
    }

    func styleCircleIsValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }

    func styleCircleShowToast(_ message: String) {
        RunwaySignalHUDCenter.shared.runwaySignalShowToast(message, kind: .error)
    }
}

private struct StyleCircleRegistrationRoute: Identifiable {
    let id = UUID()
    let styleCircleEmail: String
    let styleCirclePassword: String

    var styleCircleWebPath: String {
        "register"
    }
}

private enum StyleCircleAuthFocus {
    case email
    case password
    case confirmPassword
}

enum StyleCircleAuthMode {
    case signIn
    case signUp
    case forgotPassword

    var lookbookShareTitle: String {
        switch self {
        case .signIn:
            "SIGN IN"
        case .signUp:
            "SIGN UP"
        case .forgotPassword:
            "Forgot password"
        }
    }

    var runwayMomentPrimaryTitle: String {
        switch self {
        case .signIn:
            "Sign in"
        case .signUp:
            "Sign up"
        case .forgotPassword:
            "NEXT"
        }
    }

    var styleCircleShowsConfirmPassword: Bool {
        self != .signIn
    }
}

private struct StyleCircleAuthBackdrop: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: LookbookShareColorStyle.runwayGlowYellow, location: 0),
                .init(color: Color(red: 1.0, green: 0.88, blue: 0.44), location: 0.16),
                .init(color: LookbookShareColorStyle.lookbookSoftCanvas, location: 0.46),
                .init(color: LookbookShareColorStyle.lookbookSoftCanvas, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct StyleCircleAuthHeader: View {
    let styleCircleAuthMode: StyleCircleAuthMode
    let runwayMomentBackAction: () -> Void

    var body: some View {
        HStack {
            Button {
                runwayMomentBackAction()
            } label: {
                Image("SARTY_back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .opacity(styleCircleAuthMode == .signIn ? 1 : 1)
    }
}

private struct StyleCirclePasswordBlock: View {
    let styleCircleAuthMode: StyleCircleAuthMode
    @Binding var closetChatPasswordText: String
    @Binding var closetChatConfirmPasswordText: String
    let styleCircleFocusedField: FocusState<StyleCircleAuthFocus?>.Binding
    let runwayMomentForgotAction: () -> Void
    @State private var trendVibeShowsPassword = false
    @State private var trendVibeShowsConfirmPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Password")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)

                Spacer()

                if styleCircleAuthMode == .signIn {
                    Button {
                        runwayMomentForgotAction()
                    } label: {
                        Text("FORGOT?")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(LookbookShareColorStyle.runwayGlowYellow)
                    }
                    .buttonStyle(.plain)
                }
            }

            StyleCirclePasswordField(
                runwayMomentPlaceholder: "Enter password",
                closetChatPasswordText: $closetChatPasswordText,
                trendVibeShowsPassword: $trendVibeShowsPassword,
                styleCircleFocusedField: styleCircleFocusedField,
                runwayMomentFocusValue: .password
            )

            if styleCircleAuthMode.styleCircleShowsConfirmPassword {
                StyleCirclePasswordField(
                    runwayMomentPlaceholder: "Please enter the password again",
                    closetChatPasswordText: $closetChatConfirmPasswordText,
                    trendVibeShowsPassword: $trendVibeShowsConfirmPassword,
                    styleCircleFocusedField: styleCircleFocusedField,
                    runwayMomentFocusValue: .confirmPassword
                )
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

private struct StyleCirclePasswordField: View {
    let runwayMomentPlaceholder: String
    @Binding var closetChatPasswordText: String
    @Binding var trendVibeShowsPassword: Bool
    let styleCircleFocusedField: FocusState<StyleCircleAuthFocus?>.Binding
    let runwayMomentFocusValue: StyleCircleAuthFocus

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if trendVibeShowsPassword {
                    TextField(runwayMomentPlaceholder, text: $closetChatPasswordText)
                        .focused(styleCircleFocusedField, equals: runwayMomentFocusValue)
                } else {
                    SecureField(runwayMomentPlaceholder, text: $closetChatPasswordText)
                        .focused(styleCircleFocusedField, equals: runwayMomentFocusValue)
                }
            }
            .font(.system(size: 13, weight: .regular))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .tint(LookbookShareColorStyle.runwayGlowYellow)

            Button {
                trendVibeShowsPassword.toggle()
                styleCircleFocusedField.wrappedValue = runwayMomentFocusValue
            } label: {
                Image(systemName: trendVibeShowsPassword ? "eye.slash" : "eye")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk.opacity(0.46))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(trendVibeShowsPassword ? "Hide password" : "Show password")
        }
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .frame(height: 52)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

private struct StyleCircleAuthField: View {
    let runwayMomentTitle: String
    let runwayMomentPlaceholder: String
    @Binding var runwayMomentText: String
    let runwayMomentFocus: FocusState<StyleCircleAuthFocus?>.Binding
    let runwayMomentFocusValue: StyleCircleAuthFocus

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(runwayMomentTitle)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(LookbookShareColorStyle.styleCircleInk)

            TextField(runwayMomentPlaceholder, text: $runwayMomentText)
                .font(.system(size: 13, weight: .regular))
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding(.horizontal, 18)
                .frame(height: 52)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .tint(LookbookShareColorStyle.runwayGlowYellow)
                .focused(runwayMomentFocus, equals: runwayMomentFocusValue)
        }
    }
}
