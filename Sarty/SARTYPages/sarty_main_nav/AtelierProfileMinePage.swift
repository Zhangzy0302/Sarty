import SwiftUI

struct AtelierProfileMinePage: View {
    let atelierProfileWebRouteAction: (String) -> Void
    @StateObject private var atelierProfileUserViewModel = ClosetProfileUserViewModel()
    @StateObject private var atelierProfilePostViewModel = LookbookPostVideoViewModel()
    @State private var atelierProfileMyWorks: [LookbookPostVideo] = []

    init(atelierProfileWebRouteAction: @escaping (String) -> Void = { _ in }) {
        self.atelierProfileWebRouteAction = atelierProfileWebRouteAction
    }

    var body: some View {
        ZStack(alignment: .top) {
            CatwalkKitTopGlow()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    AtelierProfileHeader(
                        atelierProfileUser: atelierProfileUserViewModel.currentUser,
                        atelierProfileWebRouteAction: atelierProfileWebRouteAction
                    )
                        .padding(.top, 24)

                    AtelierProfileCoinBanner(
                        atelierProfileCoins: atelierProfileUserViewModel.currentUser?.closetProfileWalletBalance ?? 0,
                        atelierProfileWebRouteAction: atelierProfileWebRouteAction
                    )

                    Text("Works")
                        .font(.system(size: 19, weight: .heavy))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                        .padding(.leading, 4)

                    VStack(spacing: 14) {
                        ForEach(atelierProfileMyWorks) { atelierProfilePost in
                            AtelierProfileWorkCard(
                                atelierProfilePost: atelierProfilePost,
                                atelierProfileUser: atelierProfileUserViewModel.currentUser,
                                atelierProfilePostRouteAction: atelierProfileWebRouteAction
                            )
                        }

                        if atelierProfileMyWorks.isEmpty {
                            CatwalkKitEmptyState(
                                catwalkKitTitle: "No works yet.",
                                catwalkKitTopPadding: 0,
                                catwalkKitVerticalPadding: 28
                            )
                        }
                    }
                    .padding(.bottom, 112)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            atelierProfileLoadMineData()
        }
    }

    private func atelierProfileLoadMineData() {
        atelierProfileUserViewModel.loadLoginClosetProfileUser()
        atelierProfileMyWorks = atelierProfilePostViewModel.getMyLookbookPostWorks()
    }
}

private struct AtelierProfileHeader: View {
    let atelierProfileUser: ClosetProfileUser?
    let atelierProfileWebRouteAction: (String) -> Void

    private var atelierProfileDisplayName: String {
        CatwalkKitProfileText.displayName(atelierProfileUser)
    }

    private var atelierProfileInitials: String {
        CatwalkKitProfileText.initials(atelierProfileDisplayName)
    }

    private var atelierProfileAvatarURL: String {
        atelierProfileUser?.closetProfileAvatar ?? ""
    }

    private var atelierProfileGradient: [Color] {
        CatwalkKitPalette.pick(seed: atelierProfileUser?.closetProfileUserId ?? atelierProfileDisplayName)
    }

    var body: some View {
        ZStack(alignment: .topLeading){
            
            
            HStack(alignment: .top, spacing: 14) {
                

                VStack(alignment: .leading, spacing: 27) {
                    HStack {
                        
                        Button {
                            atelierProfileWebRouteAction("edit")
                        } label: {
                            HStack(spacing: 4) {
                                Text(atelierProfileDisplayName)
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .layoutPriority(1)
                                Image("SARTY_icon_edit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                            }
                            .padding(.leading, 87)
                        }
                        .buttonStyle(.plain)
                        .layoutPriority(1)

                        Spacer(minLength: 8)

                        Button {
                            atelierProfileWebRouteAction("setting")
                        } label: {
                            HStack(spacing: 6) {
                                Image("SARTY_setting")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                Text("Settings")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(LookbookShareColorStyle.runwayGlowYellow)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .fixedSize(horizontal: true, vertical: false)
                    }

                    HStack(spacing: 6) {
                        Button {
                            atelierProfileWebRouteAction("fan")
                        } label: {
                            HStack(spacing: 6) {
                                Text("\(atelierProfileUser?.closetProfileFans.count ?? 0)")
                                    .font(.system(size: 15, weight: .heavy))
                                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                                Text("Fans")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.45))
                            }.contentShape(.capsule)
                        }
                        .buttonStyle(.plain)

                        Button {
                            atelierProfileWebRouteAction("follow")
                        } label: {
                            HStack(spacing: 6) {
                                Text("\(atelierProfileUser?.closetProfileFollowing.count ?? 0)")
                                    .font(.system(size: 15, weight: .heavy))
                                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                                    .padding(.leading, 10)
                                Text("Followings")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.45))
                            }.contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.top, 16)
            
            CatwalkKitRemoteAvatar(
                catwalkKitAvatarURL: atelierProfileAvatarURL,
                catwalkKitInitials: atelierProfileInitials,
                catwalkKitDiameter: 75,
                catwalkKitGradient: atelierProfileGradient
            )
            .padding(.leading, 12)
        }
        
    }
}

private struct AtelierProfileCoinBanner: View {
    let atelierProfileCoins: Int
    let atelierProfileWebRouteAction: (String) -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image("SARTY_coin")
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 3) {
                Text("Coins Balance")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
                Text("\(atelierProfileCoins)")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)
            }

            Spacer()

            Text("Recharge")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 17)
                .frame(height: 34)
                .background(LookbookShareColorStyle.runwayGlowYellow)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
        .background(
            Image("SARTY_wallet_bg")
                .resizable()
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            atelierProfileWebRouteAction("coins")
        }
    }
}

private struct AtelierProfileWorkCard: View {
    let atelierProfilePost: LookbookPostVideo
    let atelierProfileUser: ClosetProfileUser?
    let atelierProfilePostRouteAction: (String) -> Void

    private var atelierProfileName: String {
        CatwalkKitProfileText.displayName(atelierProfileUser)
    }

    private var atelierProfileInitials: String {
        CatwalkKitProfileText.initials(atelierProfileName)
    }

    private var atelierProfileCaption: String {
        let atelierProfileText = atelierProfilePost.lookbookPostTextContent.trimmingCharacters(in: .whitespacesAndNewlines)
        return atelierProfileText.isEmpty ? "Share your outfit mood..." : atelierProfileText
    }

    private var atelierProfileTypeTitle: String {
        let atelierProfilePostThemes = [
            "Formal",
            "Leisure",
            "Exquisite"
        ]
        let atelierProfileThemeIndex = atelierProfilePost.lookbookPostTitleType

        guard atelierProfilePostThemes.indices.contains(atelierProfileThemeIndex) else {
            return "# Theme"
        }

        return "# \(atelierProfilePostThemes[atelierProfileThemeIndex])"
    }

    private var atelierProfileLikes: String {
        CatwalkKitNumberFormatter.compact(atelierProfilePost.lookbookPostLikeCount)
    }

    private var atelierProfileIsLiked: Bool {
        atelierProfileUser?.closetProfileLikePosts.contains(atelierProfilePost.lookbookPostWorkId) == true
    }

    private var atelierProfileGradient: [Color] {
        CatwalkKitPalette.pick(seed: atelierProfilePost.lookbookPostWorkId, from: CatwalkKitPalette.catwalkKitPostPalettes)
    }

    private var atelierProfileDetailsPath: String {
        if atelierProfilePost.lookbookPostType == 1 {
            return "videoPostDetails/\(atelierProfilePost.lookbookPostWorkId)"
        }

        return "picPostDetails/\(atelierProfilePost.lookbookPostWorkId)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                CatwalkKitAvatar(
                    catwalkKitInitials: atelierProfileInitials,
                    catwalkKitDiameter: 28,
                    catwalkKitGradient: atelierProfileGradient
                )

                Text(atelierProfileName)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    .lineLimit(1)

                Text(atelierProfileTypeTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.35))
                    .padding(.horizontal, 12)
                    .frame(height: 24)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Capsule())

                Spacer()

            }

            ZStack(alignment: .bottom) {
                AtelierProfileWorkMedia(
                    atelierProfilePost: atelierProfilePost,
                    atelierProfileGradient: atelierProfileGradient
                )

                LinearGradient(colors: [.clear, Color.black.opacity(0.48)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 56)

                HStack {
                    Text(atelierProfileCaption)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(atelierProfileIsLiked ? "SARTY_like" : "SARTY_like_no")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        Text(atelierProfileLikes)
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture {
            atelierProfilePostRouteAction(atelierProfileDetailsPath)
        }
    }
}

private struct AtelierProfileWorkMedia: View {
    let atelierProfilePost: LookbookPostVideo
    let atelierProfileGradient: [Color]

    var body: some View {
        if atelierProfilePost.lookbookPostType == 1 {
            ZStack {
                CatwalkKitRemotePhotoTile(
                    catwalkKitSource: atelierProfilePost.lookbookPostPic.first ?? "",
                    catwalkKitGradient: atelierProfileGradient,
                    catwalkKitCornerRadius: 0
                )
                .frame(maxWidth: .infinity)
                .frame(height: 176)

                Image("SARTY_icon_play")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
            }
        } else {
            ZStack(alignment: .topTrailing) {
                CatwalkKitRemotePhotoTile(
                    catwalkKitSource: atelierProfilePost.lookbookPostPic.first ?? "",
                    catwalkKitGradient: atelierProfileGradient,
                    catwalkKitCornerRadius: 0
                )
                .frame(maxWidth: .infinity)
                .frame(height: 176)
                
                if atelierProfilePost.lookbookPostPic.count > 1 {
                    Text("+ \(atelierProfilePost.lookbookPostPic.count - 1)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.black.opacity(0.6))
                        )
                        .padding(10)
                }
            }
        }
    }
}
